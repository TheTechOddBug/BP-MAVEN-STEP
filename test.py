from bs4 import BeautifulSoup

html_file_path = "report.html"

with open(html_file_path, "r", encoding="utf-8") as file:
    html_content = file.read()

soup = BeautifulSoup(html_content, "html.parser")
table_data = {}

# Find the <h4> tag with text containing 'Summary'
summary_header = soup.find(lambda tag: tag.name in ["h3", "h4", "h2"] and "Summary" in tag.get_text())
target_table = summary_header.find_next("Summary") if summary_header else None

if target_table:
    for row in target_table.find_all("tr"):
        cols = row.find_all("td")
        if len(cols) == 2:
            key = cols[0].get_text(strip=True)
            value = cols[1].get_text(strip=True)
            table_data[key] = value

    for k, v in table_data.items():
        print(f"{k} -> {v}")
else:
    print("Specified table not found in the HTML file.")
