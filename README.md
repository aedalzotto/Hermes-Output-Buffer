# Hermes Output Buffered

The Hermes NoC is a parameterizable infrastructure used to implement low area overhead wormhole packet switching NoCs with 2D mesh topology. The original project consisted of a centralized switching logic with five bi-directional ports in each router.

The output buffered Hermes distributes the routing for each input port which has 4 buffers to where the packet will be routed following the XY algorithm. Each output port has its own arbiter which selects an output buffer to make available at it's output following the Round-Robin algorithm, then avoiding starvation.

This project is intended to be used alongside with Atlas, providing an ease generation of the parametrizable NoC and its evaluation. Power estimation for this model is still not available.

## About Atlas

The Atlas environment automates the various processes related to the design flow for some of NoCs proposed by the GAPH Group and eventually by other groups with which we collaborate. Currently, the design flow is composed by the following stages: NoC generation, traffic generation, simulation, performance and power evaluation. In the NoC generation, the NoC parameters (for example, channel bandwidth, buffer depth, number of virtual channels, flow control strategies) are configured. In the traffic generation, the traffic sceneries are generated to characterize the applications which execute on the NoC. In the simulation, the traffic data are injected in the NoC, occurring in this step the effective communication among the cores. In the performance evaluation, it is possible to generate graphics, tables, maps and reports to help in the analysis of obtained results.

## Prerequisites

The co-simulation (VHDL + SystemC) can be done with ModelSim. At least experimental C++11 is needed by the `sccom` compiler.

## Evaluating

Manual evaluation can be done placing the input files in the repository root following the name `in#.txt`, where `#` is the index of the node where the packet will be injected. See the [Input Module Source](modules/InputModule.cpp) for the packet format.

The NoC parameters can be set in the [VHDL](hermes/constants.vhd) and [SystemC](modules/constants.hpp) constants files.

To run, simply execute the `simulate.do` script, commenting anything below the `run` line (including itself). A `wave.do` including some routers path for a 3x3 NoC and a `wave_input.do` including de packet injector signals are bundled with the project.

## Credits

* **Contributors** of the [ATLAS environment](https://corfu.pucrs.br/redmine/projects/atlas)