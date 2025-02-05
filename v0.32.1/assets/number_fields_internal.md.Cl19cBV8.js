import{_ as n,c as t,j as e,a as l,a6 as s,o as i}from"./chunks/framework.Bo6Z7XO3.js";const V=JSON.parse('{"title":"Internals","description":"","frontmatter":{},"headers":[],"relativePath":"number_fields/internal.md","filePath":"number_fields/internal.md","lastUpdated":null}'),o={name:"number_fields/internal.md"},a=e("h1",{id:"Internals",tabindex:"-1"},[l("Internals "),e("a",{class:"header-anchor",href:"#Internals","aria-label":'Permalink to "Internals {#Internals}"'},"​")],-1),d=e("h2",{id:"Types-of-number-fields",tabindex:"-1"},[l("Types of number fields "),e("a",{class:"header-anchor",href:"#Types-of-number-fields","aria-label":'Permalink to "Types of number fields {#Types-of-number-fields}"'},"​")],-1),r=e("p",null,"Number fields, in Hecke, come in several different types:",-1),m=e("code",null,"AbsSimpleNumField",-1),c={class:"MathJax",jax:"SVG",style:{direction:"ltr",position:"relative"}},p={style:{overflow:"visible","min-height":"1px","min-width":"1px","vertical-align":"-0.437ex"},xmlns:"http://www.w3.org/2000/svg",width:"1.955ex",height:"2.011ex",role:"img",focusable:"false",viewBox:"0 -696 864 889","aria-hidden":"true"},h=s('<g stroke="currentColor" fill="currentColor" stroke-width="0" transform="scale(1,-1)"><g data-mml-node="math"><g data-mml-node="TeXAtom" data-mjx-texclass="ORD"><g data-mml-node="mi"><path data-c="1D410" d="M64 339Q64 431 96 502T182 614T295 675T420 696Q469 696 481 695Q620 680 709 589T798 339Q798 255 768 184Q720 77 611 26L600 21Q635 -26 682 -26H696Q769 -26 769 0Q769 7 774 12T787 18Q805 18 805 -7V-13Q803 -64 785 -106T737 -171Q720 -183 697 -191Q687 -193 668 -193Q636 -193 613 -182T575 -144T552 -94T532 -27Q531 -23 530 -16T528 -6T526 -3L512 -5Q499 -7 477 -8T431 -10Q393 -10 382 -9Q238 8 151 97T64 339ZM326 80Q326 113 356 138T430 163Q492 163 542 100L553 86Q554 85 561 91T578 108Q637 179 637 330Q637 430 619 498T548 604Q500 641 425 641Q408 641 390 637T347 623T299 590T259 535Q226 469 226 338Q226 244 246 180T318 79L325 74Q326 74 326 80ZM506 58Q480 112 433 112Q412 112 395 104T378 77Q378 44 431 44Q480 44 506 58Z" style="stroke-width:3;"></path></g></g></g></g>',1),u=[h],_=e("mjx-assistive-mml",{unselectable:"on",display:"inline",style:{top:"0px",left:"0px",clip:"rect(1px, 1px, 1px, 1px)","-webkit-touch-callout":"none","-webkit-user-select":"none","-khtml-user-select":"none","-moz-user-select":"none","-ms-user-select":"none","user-select":"none",position:"absolute",padding:"1px 0px 0px 0px",border:"0px",display:"block",width:"auto",overflow:"hidden"}},[e("math",{xmlns:"http://www.w3.org/1998/Math/MathML"},[e("mrow",{"data-mjx-texclass":"ORD"},[e("mi",{mathvariant:"bold"},"Q")])])],-1),f=e("code",null,"AbsNonSimpleNumField",-1),T={class:"MathJax",jax:"SVG",style:{direction:"ltr",position:"relative"}},x={style:{overflow:"visible","min-height":"1px","min-width":"1px","vertical-align":"-0.437ex"},xmlns:"http://www.w3.org/2000/svg",width:"1.955ex",height:"2.011ex",role:"img",focusable:"false",viewBox:"0 -696 864 889","aria-hidden":"true"},Q=s('<g stroke="currentColor" fill="currentColor" stroke-width="0" transform="scale(1,-1)"><g data-mml-node="math"><g data-mml-node="TeXAtom" data-mjx-texclass="ORD"><g data-mml-node="mi"><path data-c="1D410" d="M64 339Q64 431 96 502T182 614T295 675T420 696Q469 696 481 695Q620 680 709 589T798 339Q798 255 768 184Q720 77 611 26L600 21Q635 -26 682 -26H696Q769 -26 769 0Q769 7 774 12T787 18Q805 18 805 -7V-13Q803 -64 785 -106T737 -171Q720 -183 697 -191Q687 -193 668 -193Q636 -193 613 -182T575 -144T552 -94T532 -27Q531 -23 530 -16T528 -6T526 -3L512 -5Q499 -7 477 -8T431 -10Q393 -10 382 -9Q238 8 151 97T64 339ZM326 80Q326 113 356 138T430 163Q492 163 542 100L553 86Q554 85 561 91T578 108Q637 179 637 330Q637 430 619 498T548 604Q500 641 425 641Q408 641 390 637T347 623T299 590T259 535Q226 469 226 338Q226 244 246 180T318 79L325 74Q326 74 326 80ZM506 58Q480 112 433 112Q412 112 395 104T378 77Q378 44 431 44Q480 44 506 58Z" style="stroke-width:3;"></path></g></g></g></g>',1),b=[Q],w=e("mjx-assistive-mml",{unselectable:"on",display:"inline",style:{top:"0px",left:"0px",clip:"rect(1px, 1px, 1px, 1px)","-webkit-touch-callout":"none","-webkit-user-select":"none","-khtml-user-select":"none","-moz-user-select":"none","-ms-user-select":"none","user-select":"none",position:"absolute",padding:"1px 0px 0px 0px",border:"0px",display:"block",width:"auto",overflow:"hidden"}},[e("math",{xmlns:"http://www.w3.org/1998/Math/MathML"},[e("mrow",{"data-mjx-texclass":"ORD"},[e("mi",{mathvariant:"bold"},"Q")])])],-1),g=e("li",null,[e("p",null,[e("code",null,"RelSimpleNumField"),l(": a finite simple extension of a number field. This is actually parametried by the (element) type of the coefficient field. The complete type of an extension of an absolute field ("),e("code",null,"AbsSimpleNumField"),l(") is "),e("code",null,"RelSimpleNumField{AbsSimpleNumFieldElem}"),l(". The next extension thus will be "),e("code",null,"RelSimpleNumField{RelSimpleNumFieldElem{AbsSimpleNumFieldElem}}"),l(".")])],-1),y=e("li",null,[e("p",null,[e("code",null,"RelNonSimpleNumField"),l(": extensions of number fields given by several polynomials. This too will be referred to as a non-simple field.")])],-1),v=s('<p>The simple types <code>AbsSimpleNumField</code> and <code>RelSimpleNumField</code> are also called simple fields in the rest of this document, <code>RelSimpleNumField</code> and <code>RelNonSimpleNumField</code> are referred to as relative extensions while <code>AbsSimpleNumField</code> and <code>AbsNonSimpleNumField</code> are called absolute.</p><p>Internally, simple fields are essentially just (univariate) polynomial quotients in a dense representation, while non-simple fields are multivariate quotient rings, thus have a sparse presentation. In general, simple fields allow much faster arithmetic, while the non-simple fields give easy access to large degree fields.</p><h2 id="Absolute-simple-fields" tabindex="-1">Absolute simple fields <a class="header-anchor" href="#Absolute-simple-fields" aria-label="Permalink to &quot;Absolute simple fields {#Absolute-simple-fields}&quot;">​</a></h2><p>The most basic number field type is that of <code>AbsSimpleNumField</code>. Internally this is essentially represented as a unvariate quotient with the arithmetic provided by the C-library antic with the binding provided by Nemo.</p>',4);function N(S,A,k,F,I,R){return i(),t("div",null,[a,d,r,e("ul",null,[e("li",null,[e("p",null,[m,l(": a finite simple extension of the rational numbers "),e("mjx-container",c,[(i(),t("svg",p,u)),_])])]),e("li",null,[e("p",null,[f,l(": a finite extension of "),e("mjx-container",T,[(i(),t("svg",x,b)),w]),l(" given by several polynomials. We will refer to this as a non-simple field - even though mathematically we can find a primitive elements.")])]),g,y]),v])}const j=n(o,[["render",N]]);export{V as __pageData,j as default};
