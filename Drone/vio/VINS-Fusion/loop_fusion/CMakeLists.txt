cmake_minimum_required(VERSION 2.8.3)
project(loop_fusion)

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_CXX_STANDARD 11)
#-DEIGEN_USE_MKL_ALL")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -Wall -g")

find_package(catkin REQUIRED COMPONENTS
    roscpp
    std_msgs
    nav_msgs
    camera_models
    cv_bridge
    roslib
    )

find_package(OpenCV 4 REQUIRED)


find_package(Ceres REQUIRED)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
find_package(Eigen3)

include_directories(${OpenCV_INCLUDE_DIRS} ${catkin_INCLUDE_DIRS} ${CERES_INCLUDE_DIRS} ${EIGEN3_INCLUDE_DIR})

catkin_package()

add_executable(loop_fusion_node
    src/pose_graph_node.cpp
    src/pose_graph.cpp
    src/keyframe.cpp
    src/utility/CameraPoseVisualization.cpp
    src/ThirdParty/DBoW/BowVector.cpp
    src/ThirdParty/DBoW/FBrief.cpp
    src/ThirdParty/DBoW/FeatureVector.cpp
    src/ThirdParty/DBoW/QueryResults.cpp
    src/ThirdParty/DBoW/ScoringObject.cpp
    src/ThirdParty/DUtils/Random.cpp
    src/ThirdParty/DUtils/Timestamp.cpp
    src/ThirdParty/DVision/BRIEF.cpp
    src/ThirdParty/VocabularyBinary.cpp
    )

target_link_libraries(loop_fusion_node
    ${catkin_LIBRARIES}
    ${OpenCV_LIBS}
    ${CERES_LIBRARIES}
    # 既然变量是空的，我们就直接告诉它库在哪里！
    /usr/local/lib/libopencv_core.so
    /usr/local/lib/libopencv_highgui.so
    /usr/local/lib/libopencv_imgproc.so
    /usr/local/lib/libopencv_imgcodecs.so
    /usr/local/lib/libopencv_videoio.so
    /usr/local/lib/libopencv_calib3d.so
    # 下面这两个是 Loop Fusion 特有的，必须加！
    /usr/local/lib/libopencv_features2d.so
    # /usr/local/lib/libopencv_xfeatures2d.so
)
