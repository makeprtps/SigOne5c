// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */
 

module counter_multiply_reg #(
    parameter BITS = 32
)(
    input clk,
    input reset,
    input valid,
    input [3:0] wstrb,
    input [BITS-1:0] wdata,
    input [BITS-1:0] la_write,
    input [BITS-1:0] la_input,
    output ready,
    output [BITS-1:0] rdata,
    output [BITS-1:0] count
);
    reg ready;
    reg [BITS-1:0] count;
    reg [BITS-1:0] rdata;
    
    reg [4:0]  la_write_1d;
    reg [4:0]  la_write_2d;
    reg [4:0]  la_write_3d;
    reg [4:0]  la_write_4d;
    
    reg [4:0]  la_input_1d;
    reg [4:0]  la_input_2d;
    reg [4:0]  la_input_3d;
    reg [4:0]  la_input_4d;
    
    wire [7:0] multi_out;
    
    reg [7:0] multi_out_1d;
    reg [7:0] multi_out_2d;
    reg [7:0] multi_out_3d;
    reg [7:0] multi_out_4d;
    
    
    always @(posedge clk) begin
        if (reset) begin
            la_write_1d <= 0;
            la_write_2d <= 0;
            la_write_3d <= 0;
            la_write_4d <= 0;
            
            la_input_1d <= 0;
            la_input_2d <= 0;
            la_input_3d <= 0;
            la_input_4d <= 0;
            
            multi_out_1d <= 0;
            multi_out_2d <= 0;
            multi_out_3d <= 0;
            multi_out_4d <= 0;
        end 
        else begin
        	la_write_1d <= la_write[4:0];
        	la_write_2d <= la_write_1d;
        	la_write_3d <= la_write_2d;
        	la_write_4d <= la_write_3d;
        	
        	la_input_1d <= la_input[4:0];
        	la_input_2d <= la_input_1d;
        	la_input_3d <= la_input_2d;
        	la_input_4d <= la_input_3d;
        	
        	multi_out_1d <= multi_out;
        	multi_out_2d <= multi_out_1d;
        	multi_out_3d <= multi_out_2d;
        	multi_out_4d <= multi_out_3d;
        end
    end
    
    assign multi_out = la_write_4d * la_input_4d;

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            ready <= 0;
        end else begin
            ready <= 1'b0;
            if (~|la_write) begin
                count <= count + 1;
            end
            if (valid && !ready) begin
                ready <= 1'b1;
                rdata <= count;
                if (wstrb[0]) count[7:0]   <= wdata[7:0];
                if (wstrb[1]) count[15:8]  <= wdata[15:8];
                if (wstrb[2]) count[23:16] <= wdata[23:16];
                if (wstrb[3]) count[31:24] <= wdata[31:24];
            end else if (|la_write) begin
                count[7:0] <= multi_out_4d;
            end
        end
    end

endmodule
`default_nettype wire
