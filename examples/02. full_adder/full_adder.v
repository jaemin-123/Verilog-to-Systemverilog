module full_adder (iX, iY, iCIN, oSUM, oCARRY);

    input iX, iY, iCIN;
    output oSUM, oCARRY;

    reg s0, c0, c1;
    reg sum, carry;

    assign oSUM = sum;
    assign oCARRY = carry;

    always @(iX or iY or iCIN) begin
        s0 = iX ^ iY;
        c0 = iX & iY;
        c1 = s0 & iCIN;
        sum = s0 ^ iCIN;
        carry = c0 | c1;
    end
endmodule

