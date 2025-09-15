class calculator #(type TYPE);
protected TYPE a,b;
 
function new(TYPE value1, TYPE value2 );
this.a = value1;
this.b = value2;
endfunction

//Add
virtual function TYPE add();
return a + b;
endfunction

//Subtract
virtual function TYPE sub();
return a - b;
endfunction

//Multiply
virtual function TYPE mult();
return a * b;
endfunction

function TYPE get_a();
    return a;
endfunction
  
function TYPE get_b();
    return b;
endfunction
  
endclass
