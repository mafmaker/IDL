function unitv, p
n = sqrt(total(p*p))
if n ne 0 then return, p/n
return, p
end
