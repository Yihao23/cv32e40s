#include "Vtb_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdio>

#define TIMEOUT_CYCLES 100000
#define RESET_CYCLES   10

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    Vtb_top* top = new Vtb_top;

    // VCD trace (enabled with +trace)
    VerilatedVcdC* tfp = nullptr;
    if (Verilated::commandArgsPlusMatch("trace")) {
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);
        tfp->open("trace.vcd");
    }

    // Initial state
    top->clk   = 0;
    top->rst_n = 0;

    vluint64_t sim_time = 0;
    int cycle = 0;

    while (!Verilated::gotFinish() && cycle < TIMEOUT_CYCLES) {
        // Toggle clock: falling edge
        top->clk = 0;
        top->eval();
        if (tfp) tfp->dump(sim_time);
        sim_time++;

        // Toggle clock: rising edge
        top->clk = 1;
        top->eval();
        if (tfp) tfp->dump(sim_time);
        sim_time++;

        cycle++;

        // Release reset after RESET_CYCLES
        if (cycle == RESET_CYCLES) {
            top->rst_n = 1;
        }
    }

    if (cycle >= TIMEOUT_CYCLES && !Verilated::gotFinish()) {
        printf("*** TIMEOUT after %d cycles ***\n", TIMEOUT_CYCLES);
    }

    top->final();
    if (tfp) { tfp->close(); delete tfp; }
    delete top;
    return 0;
}
