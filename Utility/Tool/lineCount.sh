m_line=$(find ../ -name "*.m" -exec cat {} \; |wc -l)
h_line=$(find ../ -name "*.h" -exec cat {} \; | wc -l)
((total=m_line+h_line))
echo "lines in *.h : $h_line"
echo "lines in *.m : $m_line"
echo "total:$total"
