# Clock constraint: 50 MHz target (period = 20 ns)
# Adjust frequency to explore timing limits of the design
create_clock -period 20.000 -name clk [get_ports clk]
