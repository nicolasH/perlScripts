This set of perl scripts, images and sql files allows one to locate the building extracted from the PDF on an image. 

- the sql file was generated by the perl script from the pdf file. 
- the image was generated using my PDF-JRasterizer.

Caveats :

- the extractor script only work for the 'Prevessin' pdf.
- pressing 'enter' on the webpage will not do anything. Click or activate 'locate' instead.
- still ugly.

Used perl modules :  
CAM::PDF  
DBD::SQLite  
DBI  
CGI  