#!/bin/bash
QT5=/opt/Qt/5.7/gcc_64
QMAKESPEC=$QT5/makespecs/linux-g++
PATH=$PATH:$QT5/bin
export QMAKESPEC PATH
qmake
