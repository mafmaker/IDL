function diag, array

matrix = dblarr(n_elements(array), n_elements(array))
for i=0, n_elements(array)-1 do begin
    matrix[i,i] = array[i]
endfor

return, matrix
end
