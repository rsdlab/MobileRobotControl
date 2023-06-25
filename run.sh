#!/bin/sh                                                                     

#start on workspace


rosserializer(){
    cd ~/workspace/MobileRobotControl/rtc/SFMLJoystickTovelocity2/build-linux/serializer/
                
    cp -rp TestSerializer.so ../../../../bin
            
    cd ~/workspace/MobileRobotControl

}


turtlebot_install(){
    echo "install ros package"
    sudo apt install ros-noetic-joy ros-noetic-teleop-twist-joy -y
    sudo apt install ros-noetic-teleop-twist-keyboard ros-noetic-laser-proc -y
    sudo apt install ros-noetic-rgbd-launch ros-noetic-rosserial-arduino -y
    sudo apt install ros-noetic-rosserial-python ros-noetic-rosserial-client -y
    sudo apt install ros-noetic-rosserial-msgs ros-noetic-amcl ros-noetic-map-server -y
    sudo apt install ros-noetic-move-base ros-noetic-urdf ros-noetic-xacro -y
    sudo apt install ros-noetic-compressed-image-transport ros-noetic-rqt* ros-noetic-rviz -y
    sudo apt install ros-noetic-gmapping ros-noetic-navigation ros-noetic-interactive-markers -y
    
    echo "install turtlebot3"
    sudo apt install ros-noetic-dynamixel-sdk -y
    sudo apt install ros-noetic-turtlebot3-msgs -y
    sudo apt install ros-noetic-turtlebot3 -y

    echo "install simulation environment"

    cd ~/catkin_ws/src
    
    DIR="turtlebot3_simulations"

    if [  -d $DIR ];then
        echo "not install"
    fi

    if [ ! -d $DIR ];then
        echo "install"
        git clone -b noetic-devel https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git

    fi
}

  
while :

do
                             
    echo "Please choose "
    echo "1:Collect Modules 2:System Build  3:System Run 4:Finish"
    echo -n ">>"
    read Robot

    case "$Robot" in
        "1")
            echo "collect modules"

            sleep 1

            turtlebot_install
            
            echo "finish! ";;

        "2")
            echo "system build"

            sleep 1

            cd ~/catkin_ws/

            echo "catkin_build"

            catkin build turtlebot3 turtlebot3_simulations

            source devel/setup.bash

            cd ~/workspace/MobileRobotControl
            
            ./mgr.py rtc build all -v
            
            rosserializer

            echo "finish! ";;

        "3")
            # export TURTLEBOT3_MODEL=burger
            
            isCore=`ps -ef | grep "roscore" | grep -v grep | wc -l`
            if [ $isCore != 1 ]; then #when not run roscore                    
              gnome-terminal --tab --command "roscore"                                                     
            fi
            sleep 3

            gnome-terminal --tab --command "roslaunch turtlebot3_gazebo turtlebot3_world.launch"
 
            gnome-terminal --tab --command "./mgr.py system run -v"    

            echo "finish? (y)"
            echo -n ">>"
            read fin

            #yを押したらプロセスIDを探してそのプロセスを停止させる
            if [ fin=="y" ]; then
                ross=`ps -e -o pid,cmd | grep rosmaster | grep -v grep | awk '{ print $1 }'`
                kill $ross
                rts=`ps -e -o pid,cmd | grep ./mgr.py | grep -v grep | awk '{ print $1 }'`
                kill $rts         
            
            echo "finish! "

            fi
            
            ;;


        "4")
            break ;;

        *)
            recho "Please choose from a choice"

    esac

done
