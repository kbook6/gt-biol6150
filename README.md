# gt-biol6150
combined files for projects from BIOL 4150/6150

## Structure
- `.R`         - R files
- `.ipynb`     - Jupyter Notebook files  
- `.html`      - genome info files from 1000 Genomes Project
- `.vcf`       - variant call format file       

#####################################################################################  
Project 1: Data Access and Quality Control Lab

Created in Jupyter Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs    
We took an individual from the 1000 Genomes Project and analyzed their genome through a fastq file.   
Code of note: fastqc fastp  

├── SRR393028_1.Trimmed_fastqc     # trimmed fastq file (first round trimming)   
├── SRR393028_2.Trimmed_fastqc     # trimmed fastq file (second round trimming)   
└── project1-DataAccessQC          # jupyter notebook file   

#####################################################################################  
Project 2: Read Mapping       

Created in Jupyter Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs
We further analyzed our fastqc file from Project 1 by comparing it to a reference genome and aligning it to the reference. We also evaluated the file we created.
Code of note: bwa index minimap2 samtools grep

└── project2-ReadMapping          # jupyter notebook file   

#####################################################################################  
Project 3: Variant Calling

Created in Jupyter Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs
We analyzed the SAM file created in Project 2 by generating a pileup format and calling variants.
Code of note: SAMstats samtools awk varscan grep bcftools

├── VSfiltered_SRR393028             # vsf file   
└── project13-VariantCalling         # jupyter notebook file   

#####################################################################################  
Project 4    

Created in R Studio Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs
We analyzed cohort data for type 2 diabetes.

└── project4-EHR          # R File    

#####################################################################################  
Project 5    

Created in R Studio Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs
We analyzed cohort data for type 2 diabetes and A1C levels.

└── project5-ModelingDisparities          # R file    

#####################################################################################  
Project 6    

Created in Jupyter Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs   

└── project6-VariantConsequences          # Jupyter Notebook file   

#####################################################################################  
Project 7    

Created in Jupyter Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs   

└── project7-PolygenicRiskScores          # Jupyter Notebook file    

#####################################################################################  
Project 8    

Created in Jupyter Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs   

└── project8-Pharmacogenomics          # Jupyter Notebook file  

#####################################################################################  
Project 9    

Created in Jupyter Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs   

└── project9-PCA          # Jupyter Notebook file  

#####################################################################################  
Project 10    

Created in Jupyter Notebooks from starter code provided by the BIOS4150/BIOL6150 Professor and TAs  

└── project10-AncestryInference          # Jupyter Notebook file  
