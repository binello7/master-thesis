#!/bin/bash

octave s_ChannelMiddleWeir_meshstudy_genInputs.m
./run.sh

octave s_ChannelMiddleWeir_meshstudy_extractOutputs.m
octave s_ChannelMiddleWeir_meshstudy_plotResults.m
