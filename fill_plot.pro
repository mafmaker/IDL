
pro fill_plot,x,y,ybase,color

for i=0,n_elements(x)-2 do begin

  corner1=[x(i),ybase]
  corner2=[x(i),y(i)]
  corner3=[x(i+1),y(i+1)]
  corner4=[x(i+1),ybase]

  trapezium,corner1,corner2,corner3,corner4,color

endfor


return
end
