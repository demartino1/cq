nextflow.enable.dsl=2
params.out = "$launchDir/output"
params.url = "http://tinyurl.com/cqbatch1"

process downloadUrl {
  publishDir params.out, mode: "copy", overwrite: true
  output:
    path "batch1.fasta"
  """
  wget $params.url -O batch1.fasta
  """
}

process splitSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
	path infile
  output:
    path "seq_*.fasta"
  """
  split -d -l 2 --additional-suffix=.fasta $infile seq_
  """
}

process Gcount {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infasta
  output:
    path "${infasta.getSimpleName()}_Gcounts.txt"
  """
  grep -o "G" ${infasta} | wc -l > ${infasta.getSimpleName()}_Gcounts.txt
  """
}

process GCcount {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infasta
  output:
    path "${infasta.getSimpleName()}_GCcounts.txt"
  """
  grep -o "[GC]" ${infasta} | wc -l > ${infasta.getSimpleName()}_GCcounts.txt
  """
}

process makeReport {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile
  output:
    path "finalcountExe.cvs"
	
//Combine all the output from previous process using * and make a cvs file.
  """
  cat * > countExe.cvs
  echo "# Sequence number, GCs" > finalcountExe.cvs
  cat countExe.cvs >> finalcountExe.cvs
  """
}

process makePDF {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile
  output:
    path "report.pdf"
// Using the report template create a report, adding the counts at the end
  """
  cp $projectDir/template.md report.md
  """
}
	
workflow {
  downloadUrl | splitSequences | flatten | GCcount | collect | makeReport
}