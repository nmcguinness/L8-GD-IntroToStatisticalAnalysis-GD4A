library(rvest)

count_words_html <- function(html_file) {
  page <- read_html(html_file)
  
  # Extract text from body paragraphs, headings, lists
  # Exclude: code blocks, tables, figures
  text <- page %>%
    html_nodes("p:not(.sourceCode), h1, h2, h3, h4, h5, li") %>%
    html_text() %>%
    paste(collapse = " ")
  
  # Clean up whitespace
  text <- gsub("\\s+", " ", text)
  
  # Count words
  words <- strsplit(text, "\\s+")[[1]]
  words <- words[nchar(words) > 0]  # Remove empty strings
  
  return(length(words))
}

file_name <- "Lab_Report_Sample.html"
# Use it
word_count <- count_words_html(file_name)
cat("Word count (excluding code/tables):", word_count, "\n")