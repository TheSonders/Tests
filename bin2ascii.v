`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Antonio Sánchez (@TheSonders)
// Entradas: un número hasta 99.999.999 y una señal de Start
// Salidas: una cadena de 8 caracteres ASCII de 7 bits con el número y una señal de Ready
//////////////////////////////////////////////////////////////////////////////////
module bin2ascii(
    input wire clk,
    input wire [31:0] bininput,
    input wire startsignal,
    output reg [55:0]asciioutput,
    output reg ready=1);


`define     ten_millions    32'h989680
`define     unit_millions   32'h0F4240
`define     cent_thousands  32'h0186A0
`define     ten_thousands   32'h002710
`define     unit_thousands  32'h0003E8
`define     hundreds        32'h000064
`define     tens            32'h00000A
`define     units           32'h000001
`define     ZERO            7'd48
`define     SPACE           7'd32

reg [2:0]stm=0;
reg prev_startsignal=0;
reg [31:0]divider=0;
reg [31:0]dividend=0;
reg [6:0] asciicounter=0;
reg nonZero=0;

always @(posedge clk) begin
    prev_startsignal<=startsignal;
    if (ready) begin
        if (startsignal & ~prev_startsignal) begin
            ready<=0;
            dividend<=bininput;
            divider<=`ten_millions;
            asciicounter<=`ZERO;
            nonZero<=0;
        end
    end
    else begin
        if (dividend < divider) begin
            asciicounter<=`ZERO;
            if (asciicounter==`ZERO && nonZero==0)
                asciioutput<={asciioutput[48:0],`SPACE};
            else begin
                asciioutput<={asciioutput[48:0],asciicounter};
                nonZero<=1;
            end
            stm<=stm+1;
            case (stm)
                3'd0:   begin divider<=`unit_millions;end
                3'd1:   begin divider<=`cent_thousands;end
                3'd2:   begin divider<=`ten_thousands;end
                3'd3:   begin divider<=`unit_thousands;end
                3'd4:   begin divider<=`hundreds;end
                3'd5:   begin divider<=`tens;end
                3'd6:   begin divider<=`units;end
                3'd7:   begin ready<=1;end
            endcase
        end
        else begin
            dividend<=dividend-divider;
            asciicounter<=asciicounter+1;
        end
    end
end

endmodule
