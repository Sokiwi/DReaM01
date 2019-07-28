# this script requires files in a folders keywords_pos,
# target_chunks_keywords, and txt_keywords to be placed
# as subfolders to the folder where this script is
# placed. 

shared_task <- function(ISO, fea, sou) {
	# this function takes two tables with keywords and
	# raw frequencies and makes one table where the 
	# frequencies are normalized and two columns
	# represent the two different vectors to be compared
	prepare_pos <- function(a, b) {
		u <- unique(c(a[,1], b[,1]))
		m <- matrix(0, nrow=length(u), ncol=2, dimnames=list(u, c("des", "wls")))
		w1 <- match(a[,1], u)
		m[w1,1] <- as.numeric(a[,2])
		w2 <- match(b[,1], u)
		m[w2,2] <- as.numeric(b[,2])
		m[,1] <- m[,1]/sum(m[,1])
		m[,2] <- m[,2]/sum(m[,2])
		return(m)
	}
	# using the output of the previous function this computes
	# the Jensen-Shannon divergence
	JensenShannon <- function(tables) {
		m1 <- 0.5 * (tables[,1] + tables[,2])
		T1 <- log2(tables[,1]/m1)
		T2 <- log2(tables[,2]/m1)
		if ( length(T1) > 0 ) {
			if ( !is.nan(T1) ) {
				for (i in 1:length(T1)) {
					if ( !is.na(T1[i]) ) {
						if ( T1[i]==Inf | T1[i]==-Inf ) {
							T1[i] <- 0
						}
					}
				}
			}
		}
		if ( length(T2) > 0 ) {
			if ( !is.nan(T2) ) {
				for (i in 1:length(T2)) {
					if ( !is.na(T2[i]) ) {
						if ( T2[i]==Inf | T2[i]==-Inf ) {
							T2[i] <- 0
						}
					}
				}
			}
		}
		if ( length(T1) > 0 & length(T2) > 0 ) {
			JS1 <- 0.5 * (sum(tables[,1] * T1) + sum(tables[,2] * T2))
		} else {
			JS1 <- NA
		}
		return(JS1)
	}
	# find the filename with keyword tables for the relevant WALS chapter
	wls_index <- dir("keywords_pos")
	get_title <- function(x) strsplit(x, "\\.")[[1]][1]
	wls_ch_titles <- as.vector(unlist(lapply(wls_index, get_title)))
	wls_ch_fn <- paste("keywords_pos/", wls_ch_titles[which(wls_ch_titles==fea)], ".txt", sep="")

	# find the files with keywords for all the chunks in the source
	# and make a vector of those filenames
	# so the files can be read individually and the J-S distances 
	# to the WALS keywords measured in order to find
	# the chunk that talks most about the WALS chapter topics
	sou_kws_index <- dir("txt_keywords")
	get_title2 <- function(x) strsplit(x, "\\__")[[1]][1]
	kw_titles <- as.vector(unlist(lapply(sou_kws_index, get_title2)))
	txt_kws_fns <- sou_kws_index[which(kw_titles==sou)]

	# compare the WALS keywords to each of the keywords for
	# chunks in the source and read in the keywords of the target
	# chunk thus identified
	wls_kw <- read.table(wls_ch_fn, header=FALSE, sep="\t", , quote="", na.strings="", comment.char="", stringsAsFactors=FALSE)
	JS <- c()
	for (i in 1:length(txt_kws_fns)) {
		sou_kw <- read.table(paste("txt_keywords/", txt_kws_fns[i], sep=""), quote="", na.strings="", comment.char="", header=FALSE, sep="\t", stringsAsFactors=FALSE)
		comp_pos <- prepare_pos(wls_kw, sou_kw)
		JS[i] <- JensenShannon(comp_pos)
		w_JS_min <- which(JS==min(JS))[1]
	}
	target_chunk <- txt_kws_fns[w_JS_min]
	target_kw <- read.table(paste("txt_keywords/", target_chunk, sep=""), quote="", na.strings="", comment.char="", header=FALSE, sep="\t", stringsAsFactors=FALSE)

	# compare the target keywords in target_kw to each of the items 
	# in the training set containing a value for the same WALS feature, 
	# find the best matching and assign its feature to
	# the present one
	target_chunk_index <- dir("target_chunks_keywords")
	get_index <- function(x) trimws(strsplit(x, "@")[[1]][1])
	wls_indices <- as.vector(unlist(lapply(target_chunk_index, get_index)))
	w <- which(wls_indices==strsplit(fea, " ")[[1]][1])
	if ( length(w) > 0 ) {
		JS2 <- c()
		values <- c()
		for (i in 1:length(w)) {
			comp_kw <- read.table(paste("target_chunks_keywords/", target_chunk_index[w[i]], sep=""), quote="", na.strings="", comment.char="", header=FALSE, sep="\t", stringsAsFactors=FALSE)
			prepared <- prepare_pos(target_kw, comp_kw)
			JS2[i] <- JensenShannon(prepared)
			val <- strsplit(target_chunk_index[w[i]], "@")[[1]][2]
			values[i] <- val
		}
		value <- values[which(JS2==min(JS2))[1]]
	} else {
		value <- NA
	}
	return(value)
}
