module ALU
( input wire [9:0] SW,
	input wire [3:0] KEY,
	output wire [6:0] HEX0,
	output wire [6:0] HEX2,
	output wire [6:0] HEX3,
	output wire [6:0] HEX4,
	output wire [9:0] LEDR
	 );



ALU_small Control( SW , KEY , HEX0 , HEX2 , HEX3 , HEX4 , LEDR );

endmodule

module ALU_small(
   input wire [9:0] SW,
	input wire [3:0] KEY,
	output reg [6:0] HEX0,
	output reg [6:0] HEX2,
	output reg [6:0] HEX3,
	output reg [6:0] HEX4,
	output wire [9:0] LEDR
);


	 wire clk;
 assign clk = KEY[0];
    wire [1:0] operand;
	 assign operand[0] = SW[0];
	 assign operand[1] = SW[1];
    wire sign;
	 assign sign = SW[2];
    wire [1:0] operator;
	 assign operator[0] = SW[4];
	 assign operator[1] = SW[5];
	 wire [6:0] ones_seg;
	 wire [6:0] hundreds_seg;
	 wire [6:0] tens_seg;
	 wire [6:0] operand_seg;
	  
    reg sign_result;
	 assign LEDR[1] = ~sign_result;
    reg zero_flag;
	 assign LEDR[0] = zero_flag;
     reg div_by_zero_flag;
	 assign LEDR[2] = div_by_zero_flag;
	
	 //reg [7:0] result;
	 //reg [7:0] result;
	 
	 //Converting 8-bits Binary to 3-digit BCD
	 wire [3:0] ones; // Ones digit in BCD 
	 wire [3:0] hundreds; // Hundreds digit in BCD
	 wire [3:0] tens;	// Tens digit in BCD 
 
 reg [7:0] current_result =0;  //revise this 
	 reg [7:0] c_result = 0;
    reg current_sign = 1;

    reg [1:0] past_operator = 2'b00;		 
	initial begin
	 //reg [7:0] intermediate_result;
   				//revise this
   	//revise this
	div_by_zero_flag =0;
	zero_flag =0;
	sign_result =0;
	end
    // Separate wires for module outputs
    wire [7:0] add_result,sub_result, mul_result, div_result;
    wire add_sign, mul_sign, div_sign,sub_sign;
    

	 
    // Instances of modules
    adder_subtractor2 add(
        .in1(c_result), .sign1(current_sign),
        .in2({6'b000000,operand}), .sign2(sign),
        .out(add_result), .signout(add_sign)
    );

	 adder_subtractor2 sub(
        .in1(c_result), .sign1(current_sign),
        .in2({6'b000000,operand}), .sign2(~sign),
        .out(sub_result), .signout(sub_sign)
    );

	
    Multiplier mul(
        .in1(c_result[6:0]), .sign1(current_sign),
        .in2({5'b00000,operand}), .sign2(sign),
        .out(mul_result), .signout(mul_sign)
    );

    Divisor div(
        .in1(c_result), .sign1(current_sign),
        .in2({6'b00000,operand}), .sign2(sign),
        .out(div_result), .signout(div_sign)
    );

binary_to_bcd b_to_bcd(.binary_in(current_result),.ones(ones),.tens(tens),.hundreds(hundreds));
    
	 
	  sevenseg out1(.in(ones), .out(ones_seg));
	 
	  sevenseg out2(.in(tens),.out(tens_seg));
	 
	  sevenseg out3(.in(hundreds),.out(hundreds_seg));
	 
	 sevenseg out4 (.in({2'b00,operand[1:0]}),.out(operand_seg));

	 

	always @(posedge clk) begin
	
		
            case (past_operator)  //for first time past_operator is 00 (+) to give the current number as a result
                2'b00: begin
                    current_result = add_result; // Use adder result
                    current_sign = add_sign;
						  div_by_zero_flag = 0; 
                end
                2'b01: begin
                    current_result = sub_result; // Handle subtraction if needed
                    current_sign = sub_sign;
						  div_by_zero_flag = 0; 
                end
                2'b10: begin
							
                    current_result = mul_result; // Use multiplier result
                    current_sign = mul_sign;
						  div_by_zero_flag = 0; 
                end
                2'b11: begin
                    if (operand!=0) //0 if it is divided by zero and 1 if not  
				begin
                        current_result = div_result; // Use divisor result
                        current_sign = div_sign;
			div_by_zero_flag = 0; // 1 for turning off
                    end  	else   // Division by zero 
						  begin
                        current_result = 8'b0; // Handle division by zero
			div_by_zero_flag = 1; //for turning it on
                    end
                end
         endcase

		  
		  // no need for this because code inside always and initial blocks has sequential execution not concurrent
   //intermediate_result = current_result;   //doesn't have any importance
	
sign_result = current_sign;
   zero_flag = (current_result == 8'b0);
	c_result = current_result;
  
	 past_operator <= operator;  // store the past operator for ex : (3 + 2 - 1) store + to use it next time
	 
	 HEX4 = hundreds_seg;
	 HEX3 = tens_seg;
	 HEX2 = ones_seg;
	 HEX0 = operand_seg;
	 
	 
	 
							end

	
 

endmodule

module adder_subtractor2(input [7:0] in1,input sign1,input [7:0] in2,input sign2
,output reg [7:0] out, output reg signout );

wire [7:0] result1 ,result4,result3;


//make output finalcarry if needed when enlarging the ALU
//wire finalcarry;

adder_subtractor1 m1(1'b0, in1[7:0], in2[7:0], result1[7:0]);
adder_subtractor1 m3(1'b1, in1[7:0], in2[7:0], result3[7:0]);
adder_subtractor1 m4(1'b1, in2[7:0], in1[7:0], result4[7:0]);




always@(*)
begin
if(sign1 ==1 && sign2 ==1) //both of them is positive and the result is positive and the final carry is 0 
begin
	out[7:0]=result1;
	signout=1;  //set the sign to positive sign
end

else if(sign1 ==0 && sign2 ==0) //both of them are negative
begin
	out[7:0]=result1;
	signout=0;  //set the sign to negative sign
end

else if(sign1==1 && sign2 ==0) //the first is positive and the second is negative
begin 	
if(in1[7:0]>in2[7:0])
begin
	out[7:0]=result3;
	signout=1;
end
else if(in1[7:0]<in2[7:0])
begin
	out [7:0]=result4;
	signout=0;
end
else begin
out=0;
signout=1;end
end

else if(sign1==0 && sign2 ==1) //the first is neagtive and the second is positive
begin 	
if(in1[7:0]>in2[7:0])
begin
	out[7:0]=result3;
	signout=0;
end

else if(in1[7:0]<in2[7:0])
begin
	out[7:0]=result4;
	signout=1;
end

else begin
	out=0;
signout=1; end
end // else if end

end // end of always block
endmodule



module HalfAdder(input a,input b,output sum , output carry);
assign sum=a^b;
assign carry = a&b;
endmodule

module FullAdder(input a,input b,input c,output sum,output carry);
wire carry1,sum1,carry2;
HalfAdder h1(a,b,sum1,carry1);
HalfAdder h2(sum1 , c ,sum , carry2);
assign carry = carry1 | carry2;
endmodule


	//FinalCarry isn't used in this ALU but used if inputs can produce a carry
module adder_subtractor1(input is_sub,input [7:0] in1,input  [7:0] in2,output [7:0] out);
// is_sub is 1 when just one of the two values is negative
wire [7:0] temp=in2[7:0]^{8{is_sub}}; // Determines whether we are adding or subtracting ?!
	
															
genvar i;
wire [7:0] carry;

generate
for( i=0;i<=7;i=i+1) begin : addsub

if(i==0)
begin
FullAdder f1(in1[i],temp[i],is_sub,out[i],carry[0]);
end

else  begin
FullAdder f2(in1[i],temp[i],carry[i-1],out[i],carry[i]);
end

end
endgenerate

endmodule


module binary_to_bcd (
    input [7:0] binary_in,         // 8-bit binary input
    output reg [3:0] hundreds,     // Hundreds digit
    output reg [3:0] tens,         // Tens digit
    output reg [3:0] ones          // Ones digit
);
    integer i;

    always @(*) begin
        // Initialize BCD digits to 0
        hundreds = 4'd0;
        tens     = 4'd0;
        ones     = 4'd0;

        
        for (i = 7; i >= 0; i = i - 1) begin
            
            if (hundreds >= 5) hundreds = hundreds + 3;
            if (tens >= 5)     tens     = tens + 3;
            if (ones >= 5)     ones     = ones + 3;

            // Shift the BCD digits left by 1 bit
            hundreds = {hundreds [2:0], 1'b0};
            hundreds[0] = tens[3];   // Carry from tens to hundreds

            tens = {tens [2:0], 1'b0};
            tens[0] = ones[3];       // Carry from ones to tens

            ones = {ones [2:0], 1'b0};
            ones[0] = binary_in[i];  // Carry from binary input
        end
    end
endmodule



module Multiplier(in1, sign1,in2, sign2, out, signout);


  //identify all input and output
  input wire [6:0] in1; // first input is 7 bits because the biggest number entering the operation is 81
  input wire [6:0] in2; // second input is 2 bits because the biggest number taken from the user is 3
  input wire sign1; // sign of the first number
  input wire sign2; // sign of the second number
  output reg [7:0] out; // the output of the multiplication 
  output reg signout; // the output sign

  // intermediate wires used to calculate the output by adding them
  reg [7:0] tempout1;  
  reg [7:0] tempout2;

  // the output sign will be the result of xoring the two signs with one representing the negative and zero representing the positive
 

  // the multiplication process is done as if the bit from the second input is zero output zero in intermediate wires 
  // if the bit is one shift the bit by number of times of the bit location 

  // example if in1 is 1001111 and in2 2 is 11 
  // tempout1 will be the result of shifting the in1 by number of the location of bit 1 in2 which in this case 0, tempout1 = 01001111   
  // tempout2 will be the result of shifting the in1 by number of the location of bit 1 in2 which in this case 1, tempout2 = 10011110
  // so the result of the multiplication will be the result of adding temp1 and temp2
  // out = 01001111 + 10011110 = 11101101 which is 237 
  // out = 3 * 79 = 237

 // adder_subtractor2 m7(timeout1, 1 , timeout2 ,1
//, out);
  
  always @(*) begin
    
	

	if(in1==0)
	begin
	tempout1=0;
	tempout2=0;
	signout=1;
	end

else begin

   if (in2[0]) 
       tempout1 = {1'b0, in1[6:0]}; // Note the leading 1'b0 to keep it 8 bits
    else 
       tempout1 = 8'b0;

    if (in2[1]) 
       tempout2 = {in1[6:0], 1'b0}; // Note the trailing 1'b0 to keep it 8 bits
    else 
       tempout2 = 8'b0;
	
	signout = ~(sign1 ^ sign2);

	end

	out = tempout1 + tempout2; //is done using the module 
  end
  
endmodule



module Divisor (in1, sign1, in2, sign2, out, signout);
    input [7:0] in1;
    input sign1;
    input [7:0] in2;
    input sign2;
    output reg [7:0] out;
    output reg signout;
    

    // reg [7:0] out;  // Register for storing the output
    reg [7:0] ToBeDivided; // Register for ToBeDivided, use a reg type
    reg [7:0] counter; // Increased size to handle larger quotients
//    reg dividedByZero_reg; // Register to hold the divided by zero state
   //  reg signout_reg; // Register for sign output
integer i;
    // Assign initial state for division by zero
    // assign dividedByZero = dividedByZero_reg;
     // assign signout = signout_reg;

    always @(*) begin
        // Reset the registers
        
        out = 0;
        //signout = 0;

        // If in2 is 00, we handle the divide by zero case
        

        // If in2 is 01, assign out to sign1
         if (in2 == 2'b01) begin
      
            out = in1;  // Assign the sign1 bit to the LSB of the output
        end

        // If in2 is 10, assign out to sign1 shifted
        else if (in2 == 2) begin
            
            out = {1'b0,in1[7:1]};  // Assign the sign1 to the MSB of the output and shift the rest
        end
        
// Otherwise, perform division logic
        else begin								//Dividing by 3
            
            ToBeDivided = in1;  // Assign in1 to ToBeDivided
            counter = 0;

            // Perform a simple division operation (subtract 3) until the number is smaller than 3
            // Perform division with a bounded loop
        for ( i = 0; i < 85; i = i + 1) begin
            if (ToBeDivided >= 3) begin
                ToBeDivided = ToBeDivided - 3;
                counter = counter + 1;
            end 
			end
			
            out = counter; // Assign the full counter value to the output
        end

        // Assign the signout logic based on the sign1 and sign2 values
        signout = ~(sign1 ^ sign2);  // Assuming you want signout to reflect XNOR of sign1 and sign2
    end

endmodule


// Seven-Segment Display Module
module sevenseg(
    input [3:0] in,          // 4-bit binary input
    output reg [6:0] out // Outputs to the 7-segment
);
    always @(*) begin
        case (in)
            4'b0000: out = 7'b1000000; // 0
            4'b0001: out = 7'b1111001; // 1
            4'b0010: out = 7'b0100100; // 2
            4'b0011: out = 7'b0110000; // 3
            4'b0100: out = 7'b0011001; // 4
            4'b0101: out = 7'b0010010; // 5
            4'b0110: out = 7'b0000010; // 6
            4'b0111: out = 7'b0111000; // 7
            4'b1000: out = 7'b0000000; // 8
            4'b1001: out = 7'b0010000; // 9
            default: out = 7'b1111111; // Off
        endcase
    end
endmodule