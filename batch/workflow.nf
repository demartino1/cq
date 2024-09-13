nextflow.enable.dsl=2

params.out = "$launchDir/output"
  
process downloadFile {
  publishDir params.out, mode: "copy", overwrite: true
  output:
    path "batch1.fasta"
  """
  wget https://tinyurl.com/cqbatch1 -O batch1.fasta
  """
}

process splitSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
	path infile
  output:
    path "seq_*.fasta"
  """
  split -l 2 -d --additional-suffix=.fasta $infile seq_
  """
}

process countBases {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile
  output:
    path "bases.txt"
  """
  grep -v "^>" $infile | wc -m > bases.txt
  """
}

process countSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile
  output:
    path "numseq.txt"
  """
  grep "^>" $infile | wc -l > numseq.txt
  """
}

process countRepeats {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infasta
  output:
    path "${infasta.getSimpleName()}_repeatcounts.txt"
  """
  grep -o "GCCGCG" ${infasta} | wc -l > ${infasta.getSimpleName()}_repeatcounts.txt
  """
}

process makeReport {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile
  output:
    path "finalcount.cvs"
  """
  cat * > count.cvs
  echo "# Sequence number, repeats" > finalcount.cvs
  cat count.cvs >> finalcount.cvs
  """
}
workflow {
  downloadFile | splitSequences | flatten | countRepeats | collect | makeReport
}