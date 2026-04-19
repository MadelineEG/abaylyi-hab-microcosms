  GNU nano 5.6.1                                   get_proteins_deseq.R                                             
# function to obtain mapping vector w/ locus-tag and protein from cds file
map_locus_to_protein <- function(ref_path) {
        lines <- readLines(ref_path, warn = FALSE)
        lines <- lines[grepl("\\[locus_tag=", lines)]

        # Use perl=TRUE and .*? for clean, foolproof extraction
        locus_tags <- sub(".*\\[locus_tag=(.*?)\\].*", "\\1", lines, perl = TRUE)

        proteins <- ifelse(
          grepl("\\[protein=", lines),
          sub(".*\\[protein=(.*?)\\].*", "\\1", lines, perl = TRUE),
          "Uncharacterized"
        )

        # Clean both the tags and proteins of any hidden whitespace
        locus_tags <- trimws(locus_tags)
        proteins <- trimws(proteins)

        locus_protein_map <- setNames(proteins, locus_tags)

        message(sprintf("   -> Built dictionary with %d locus tags.", length(locus_protein_map)))

        return(locus_protein_map)
}

# function to add protein column to csv with locus tags using mapping vector above
add_proteins <- function(locus_protein_map, file_pattern) {
        
        # obtain inputs, check they exist
        inputs <- list.files(pattern = file_pattern)

        if (length(inputs) == 0) {
                message("No files found matching pattern")
                return(invisible(NULL))
        }

        for (input in inputs) {
                
                # read input csv 
                df <- read.csv(input, stringsAsFactors = FALSE)
                
                # extract locus tag column from input
                locus_col <- colnames(df)[1]
        
                # use locus_protein_map to map locus tag to protein name
                df$proteinName <- locus_protein_map[ df[[locus_col]] ]

                # arrange protein name column right of locus tag
                other_cols <- setdiff(colnames(df), c(locus_col, "proteinName"))
                df <- df[, c(locus_col, "proteinName", other_cols)]

                # name output, save
                output_name <- sub("\\.csv$", "_Protein.csv", input)
                write.csv(df, output_name, row.names = FALSE)
        }
}

# set up config of ref name and relevant files for ea. species
species_config <- list(
  Ab = list(
    ref_file = "../../references/sequences/a-baylyi_cds.fna",
    pattern = ".*_Ab_Sig\\.csv$"
  ),
  Ma = list(
    ref_file = "../../references/sequences/m-aeruginosa_cds.fna",
    pattern = ".*_Ma_Sig\\.csv$"
  )
)

# loop through species and run code
for (species_name in names(species_config)) {
        ref <- species_config[[species_name]]$ref_file
        pat <- species_config[[species_name]]$pattern

        locus_protein_map <- map_locus_to_protein(ref)
        add_proteins(locus_protein_map, pat)
