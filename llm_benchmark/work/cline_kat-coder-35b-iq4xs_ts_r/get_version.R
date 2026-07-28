# Get forecast package version from CRAN
con <- url("https://cran.r-project.org/src/contrib/PACKAGES")
lines <- readLines(con)
close(con)
# Find forecast package block
idx <- grep("^Package: forecast", lines)
# Get version from next lines
for (i in idx) {
  j <- i
  while (j <= length(lines) && !grepl("^Version:", lines[j])) j <- j + 1
  if (j <= length(lines)) {
    cat("Latest forecast version:", sub("Version: ", "", lines[j]), "\n")
  }
}