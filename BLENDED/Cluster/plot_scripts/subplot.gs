function subplot(args)
nx=subwrd(args,1)
ny=subwrd(args,2)
n=subwrd(args,3)
padding=subwrd(args,4)
bm=subwrd(args,5)
tm=subwrd(args,6)
lm=subwrd(args,7)
rm=subwrd(args,8)
if (! nx>0)
  say 'Usage: subplot nx ny n [ pad [ bm [ tm [ lm [ rm ] ] ] ] ]'
  return
endif
if (! ny>0)
  say 'Usage: subplot nx ny n [ pad [ bm [ tm [ lm [ rm ] ] ] ] ]'
  return
endif
if (! n>0)
  say 'Usage: subplot nx ny n [ pad [ bm [ tm [ lm [ rm ] ] ] ] ]'
  return
endif
if (n > nx*ny)
  say 'Usage: subplot nx ny n [ pad [ bm [ tm [ lm [ rm ] ] ] ] ]'
  say 'n can not be greater than nx*ny !!!'
  return
endif
if (padding>-999)
else
   padding=0.4
endif
if (bm > 0)
else
   bm=padding
endif
if (tm > 0)
else
   tm=padding
endif
if (lm > 0)
else
   lm=padding
endif
if (rm > 0)
else
   rm=padding
endif

'q gxinfo'
dum=sublin(result,2)
xdim=subwrd(dum,4)
ydim=subwrd(dum,6)

dx = (xdim-lm-rm)/nx
dy = (ydim-tm-bm)/ny

j=ny-math_int(n/nx+0.9)+1
i=n-nx*(ny-j)

x0 = lm + (i-1)*dx + padding
x1 = lm + i*dx - padding
y0 = bm + (j-1)*dy  + padding
y1 = bm + j*dy - padding

*say x0' 'x1' 'y0' 'y1

'set parea 'x0' 'x1' 'y0' 'y1
*say bm' ' tm



