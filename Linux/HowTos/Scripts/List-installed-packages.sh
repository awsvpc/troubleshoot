rpm_list=""
package_list=""

for id in $(yum --noplugins history list all 2> /dev/null | grep -v System | sed 's/^ *//;s/ *| */|/g' | grep -E "^[0-9]+\|" | awk -F '|' '$4 == "Install" || $4 ~ /I/' | cut -d '|' -f1); do
  result=$(yum --noplugins history info $id 2> /dev/null | awk '/Packages Altered/{flag=1; next} flag' | awk '$1 == "Install"' | awk '{print $2}')
  if [ -n "$result" ]; then
    rpm_list+="$result"$'\n'
  fi
done

rpm_list=$(echo "$rpm_list" | sed '/^$/d')

while IFS= read -r package; do
  package_name=$(rpm -q --queryformat '%{NAME}\n' "$package" 2>/dev/null)
  if [ $? -eq 0 ]; then
    package_list+="$package_name"$'\n'
  fi
done <<< "$rpm_list"

package_list=$(echo "$package_list" | sort | uniq | sed '/^$/d')

echo "$package_list"
