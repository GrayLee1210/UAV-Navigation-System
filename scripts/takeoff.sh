#!/usr/bin/env bash
###############################################################################
# 全自动起飞脚本 (无遥控器)
#   流程: 预检系统健康 -> 倒计时警告 -> 触发 px4ctrl
#   px4ctrl 收到触发后会自动: 切 OFFBOARD -> 自动 arm -> 缓启动电机 -> 起飞悬停
#   依赖 ctrl_param_fpv.yaml:  no_RC:true  enable_auto_arm:true  auto_takeoff_land.enable:true
#   降落:  bash ~/Fast-Drone-250/shfiles/land.sh
###############################################################################
set -u

source /opt/ros/noetic/setup.bash
source "$HOME/Fast-Drone-250/devel/setup.bash"

ODOM_TOPIC="/Odometry_highrate"   # 与 run_ctrl.launch / px4ctrl 订阅一致

echo "================ 全自动起飞预检 ================"

# 1) px4ctrl 节点必须在运行
if ! rosnode list 2>/dev/null | grep -q "/px4ctrl"; then
  echo "[takeoff] X  px4ctrl 节点未运行 -> 先启动 run_fastlio_ego_px4.sh"
  exit 1
fi
echo "[takeoff] OK px4ctrl 在运行"

# 2) mavros 必须已连上飞控
echo "[takeoff] .. 等待 mavros 连接飞控 (最多 10s)"
conn=""
for i in $(seq 1 20); do
  conn=$(timeout 2 rostopic echo -n1 /mavros/state/connected 2>/dev/null | head -1)
  [ "$conn" = "True" ] && break
  sleep 0.5
done
if [ "$conn" != "True" ]; then
  echo "[takeoff] X  mavros 未连接飞控 (connected=$conn) -> 检查 /dev/ttyACM0 与飞控供电"
  exit 1
fi
echo "[takeoff] OK 飞控已连接"

# 3) 里程计必须在线 (否则 px4ctrl 会 'Reject AUTO_TAKEOFF. No odom!')
echo "[takeoff] .. 检查里程计 $ODOM_TOPIC (采样 5s)"
rate=$(timeout 5 rostopic hz "$ODOM_TOPIC" 2>/dev/null | grep -oE "average rate: [0-9.]+" | head -1 | grep -oE "[0-9.]+$")
if [ -z "${rate:-}" ]; then
  echo "[takeoff] X  收不到 $ODOM_TOPIC -> FAST-LIO 没在发里程计, 拒绝起飞"
  exit 1
fi
echo "[takeoff] OK 里程计在线 (~${rate} Hz)"

# 4) 起飞前警告倒计时
echo ""
echo "  !!!  无遥控器全自动起飞 — 所有人远离桨叶, 准备好断电急停  !!!"
echo "  目标悬停高度见 ctrl_param_fpv.yaml: takeoff_height (默认 1.0m)"
for s in 5 4 3 2 1; do
  echo "  起飞倒计时  $s ..."
  sleep 1
done

# 5) 触发 px4ctrl 自动起飞 (它内部自动 OFFBOARD + 自动 arm + 缓启动)
echo "[takeoff] >>> 发送起飞指令 <<<"
rostopic pub -1 /px4ctrl/takeoff_land quadrotor_msgs/TakeoffLand "takeoff_land_cmd: 1"

echo ""
echo "[takeoff] 已触发. 若被拒绝, 看 px4ctrl 终端的 'Reject AUTO_TAKEOFF...' 原因."
echo "[takeoff] 降落: bash ~/Fast-Drone-250/shfiles/land.sh"
