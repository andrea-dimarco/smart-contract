#!/bin/bash
echo Launching Echidna Container
sudo docker run -it --rm -v $PWD:/code trailofbits/eth-security-toolbox
