#!/bin/sh
INDEX="$TASK_REPORTS/index.html"

if ! voidedtech-is-report; then
  exit 0
fi

TODAY=$(date +%Y-%m-%d) 
MODTIME=""
if [ -e "$INDEX" ]; then
  MODTIME=$(stat "$INDEX" | grep "^Modify:" | cut -d " " -f 2)
fi

echo "generate report ($TODAY == $MODTIME)?"
if [ "$MODTIME" = "$TODAY" ]; then
  exit 0
fi
echo "generating..."

{
  # header
  cat << EOF
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>

body
{
    font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-size: 15px;
}

#main
{
    width: 90%;
    margin-left: auto;
    margin-right: auto;
    padding: 20px;
}

#site
{
    margin-left: auto;
    margin-right: auto;
    width: 90%;
}
</style>
<script>
function showHide(div) {
  var div = document.getElementById(div);
  if (div.style.display !== 'none') {
    div.style.display = 'none';
  } else {
    div.style.display = 'block';
  }
}
</script>
<title>report</title>
</head>
<body>
  <div id="site">
    <div id="main">
EOF

  # content
  echo "<h4>"
  date +%Y-%m-%d
  echo "</h4>"
  for SECTION in git rclone delta; do
    echo "<hr />"
    printf "<div onclick='showHide(\"%s\")'>&gt; %s</div>\n" "$SECTION" "$SECTION"
    echo "<br />"
    printf "<div id='%s'><pre>" "$SECTION"
    REPORT="$TASK_REPORTS/$SECTION"
    {
      if [ -e "$REPORT" ]; then
        cat "$REPORT"
      else
        echo "no report"
      fi
    } | recode ascii..html
    echo "</pre></div>"
    echo "<hr />"
  done
  
  # footer
  cat << EOF
    </div>
  </div>
</body>
</html>
EOF
} > "$INDEX"
