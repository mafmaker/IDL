PRO trapezium, corner1,corner2,corner3,corner4, color  
;
;  This should be called trapezium
;  provide the x and y coordinates of each corner to get you a nice
;  filled box.
;
;

   ; Call POLYFILL:  
   POLYFILL, [corner1(0), corner2(0), corner3(0), corner4(0)], [corner1(1), Corner2(1), corner3(1), corner4(1)], COL = color  
END  
