#!/usr/bin/python3
# -*- coding: utf-8 -*-

html_body = """
<!DOCTYPE html>
<html>
<head>
<title>time</title>
<style>
h1 {
font-size: 3em;
}
</style>
</head>
<body>
<h1>%s</h1>
</body>
</html>
"""

from datetime import datetime
d = datetime.now().strftime("%Y/%m/%d %H:%M:%S")

print(html_body % (d))
