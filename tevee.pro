pro tevee,image

; Program to tv array results where the bottom of the color scale
; is the lowest NON-ZERO number. This allows one to quit always having
; to type 5 lines of code to get a decent image of angles or other
; large numbers

thing=image/image
killnan,thing,0
bla=where(thing eq 1)
thing=bytscl(image,min=min(image(bla)),max=max(image(bla)))
tv,thing

stop
return
end