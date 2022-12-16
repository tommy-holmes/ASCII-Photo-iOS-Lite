# ASCII-Photo-iOS-Lite
A watered down version of my ASCII Photo iOS app. I intend to use this project to sell myself to teams of iOS engineers for their own assessment of my skills as a developer, basically a "tech test". Please also bare in mind that while this is "reviewable" there is some code that might be unused yet, this is intentional as it is a side project of mine and is still being worked on (mainly additive). 

## Reviewer info
- 100% SwiftUI
- Unit tests included for the `ImageModel`
- iOS 16+ to allow for the use of newer APIs and tools such as [Transferable](https://developer.apple.com/documentation/coretransferable/transferable)
- Mainly uses architecture that SwiftUI enforces, i.e. Models are closely tied to Views via `StateObject` which react to changes in `Published` values and propergate through environment objects, any lower level processing (such as the image generation algorithm) are isolated and _only_ the Model can directly interact with it
- Implements async-await in the `Camera` object for assessing permissions, receiving image/video streams and processing captured photos. 
- Type safety is utilised where ever possible to help with API design, code maintenance and mitigates the risk of introducing regressions, e.g. `generateArt(with glyphs: Glyphs)` uses the `Glyphs` type that has a private initialiser so the consumer has _no choice_ but to use the `static` constants (in this case `.ascii`) to call the method.  

## Features
- [x] Camera support
- [x] Photo library support
- [x] Drag and drop support
- [x] Copy generated art to clipboard 
- [x] Image preview
- [x] Generated art inversion
- [x] Light and dark mode support
- [ ] Convert generated art to an actual image
- [ ] Better UI and UX for art preview

## Demo output
### Saturn in ASCII

```
 
                                                                                                    
                                                                                                    
                                                                                  ."I<+-[[[?~,      
                                                                              ,<[(/frxrf/\\\||]     
                                                                          :+1/jjt\|)1(|rYXxft(/I    
                                                                      \<}/ft\|\/frnunj1!lrLuj/\!    
                                                                   "_)ff//jvUQZwqqqpppdp?^XUxt\.    
                                                                "-\jjtrcJOZZOQLLLLLQ0ZOpO`nJrf_     
                                                             ^_\jjjuYQZOQLJUUUYXUJCLLOZpC:Jcj)      
                                                          .>|rrrvJOZ0CYvxt|((\rccXJLLOOh}}Qrt\      
                                                        I1jxxvJOZQYn|[>I,^``^^:]czULQ0dU>Luf"       
                                                 .'. `_fnxvJ0ZLct[i"\''''\\`^"^:xXULQqZ+Yzf"        
                                         ',I<+-[]?-]/uczYQZLz/_,'          '\^^lvYLLww[vU/^         
                                     \;>-]}11(1[[1jvcYLO0Yr(?><!,          .\^`(YJCwZ{vU('          
                                  \l_]}11(()1[]\ncYCOOCu/{?[{()(1?i\       '``-XJCqL}zY[            
                                ,~]}11()|)1]}tvXUQOQXj(]}|juvuxj/)1[<\     `\~XJLpX(Uvi             
                              ,+{11()|||1](jcYC0OLvt11tvJLLJzuxjt\)}{?l   `\_XJ0qx/Ct^              
                            `~]}1(||||1{)xzULOOJn\)tc0ww0JXcvvuxjt\|({[~`'`]UCm0/xJ?                
                           l[}1()|||1{|nXULZ0Yr\/v0pkp0UXXXzcvunrf\(1{?-~;\JLwz\Xn:                 
                          >]}1))|)1{|uYJQOQXj\rCphhd0CJJJYzzcvxf/)1}{{[?_>cm0jrU{                   
                         ~]{1)||1{|uYJQZQzf\rQkakdmLLLCJUYXvxt\)(((1}}{][~]U/zr,                    
                        <]{1))}]|uXUQOQzt(fLkabqwOLLLJJUXvr/\\|))(((1}}{][</X-                      
                       :[]1)}](nXULZQzt(/JbhpmmmOLLCJUznj/\\\\|||)))(1}{[?~?^                       
                       +]1}[1xzXLOQXt1|Xdhq00mmOQLCUcxf/\/\\\\\|||))(11{]-_`                        
                      ^[{?]jzXJO0Yj((umkqQLOwwZ0LJcrt///\\\\/\\\||||)(1{[-+`                        
                      I?-/zzUOOUx)1jLbpQCQmwwZQJcrt///////////\////|)1{]?_>                         
                      :(vczQOCv|}/cmpOCLZmZO0Ccrt////\////////tt/|)(1{][_~I                         
                     IxzvJZQXt{1rJmZCCLQLJJUzrt////////////tff/\|)(1}{[-~<.                         
                   .|XrzO0Ux}[|uLZLUJJUYYUzxt////////tt//fff/||))(}{[?_>i^                          
                  ~cufCZLz|?]\vCLYzXXXXzcxt///\/////tttfjf/\||)(1{]?-+<i"                           
                `tYtvZ0Cr[_]|rXUvvcccvcnt\/\\\\\/////fjf/\|||(1}]?-+>il^                            
               +Xu/LmCY[;~?1/nurxnuuuur\||\\\\\/////ff/||||(1}][-+~<iI'                             
             '|Jtrm0Jc>\'^_1\f/ffjjrr/)))))|||\\\\/t/||))(1}][-+~>i!,                               
            !vY)XqLJul\\   i{11)|//t)(((()))||||\//|))((1{][-+~><!:.                                
           ?Uu(QwCJnI\\     `>[}1()1}}}11(())))|\|(1(}}{[?-+><il,.                                  
         \)Cj|wZCUvl``.       `i-]{[]{{}}}1111()(}}{]][--+>i!:`                                     
        :fC/|pOLUX-\^'          .:!<~+_?]{{]]]{{[[[??-+~<l,'                                        
       !rC/)dOLJYj,"`'.         .`l]t\|}~-??---_++>il;^'                                            
      <rJj]dZLLYz\"^"``\\''.'^;~1rU0ZOUnrx],                                                        
     <rzz>ww0LCYcv-:^^^^";i_1fvCOZQYurrt?`                                                          
    ljnQ<ubO0LLUzccr/|\/juzJQOZQXnrrf{;                                                             
   ^/jUnIwmZOLLLJUXYUUUCLOZOCzxjjf1i                                                                
   }fxL(;dwOO0QLLLQQOZmmQYujfjf(<.                                                                  
  ;/txCx'(pdppppqqm0Czxt/tjt}i'                                                                     
  _\tjvL/Ii1trrrf/\|\/ff|?;                                                                         
  +\)tfxXXx\))|/tfjf|]i`                                                                            
   }||\\\/frjft|{+I\                                                                                
    :>-[[?+>!,\                                                                                     
                                                                                                    
                                                                                                   
```

### Preview image

<img width="928" alt="Screenshot 2022-12-15 at 21 52 19" src="https://user-images.githubusercontent.com/59975039/207974940-671916f9-f622-4a80-9155-8f7b95092569.png">

### From the source image

![saturn](https://user-images.githubusercontent.com/59975039/207397379-29ebfb93-05dc-4955-bb59-c82a16b56688.jpg)
