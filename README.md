## Closedstack Summon script

- To run this script you need to first install jgrep, summon, and thor gems

```shell
gem install jgrep
```

- Next you'll need to copy the summon script to your local machines and make it executable

```shell
git clone https://github.com/goober2186/sm.git
chmod +x summon.sh
chmod +x provision.sh
```
- To run the script you'll need to make a server list text file formatted like this

```shell
serial1
serial2
serial3
```

- To run the script navigate to the summon script directory then run summon.sh or provision.sh formatted like this

```shell
./summon.sh -h <url> -t <closedstack api token> -f <path to server list>
./provision.sh -h <url> -t <closedstack api token> -f <path to server list> -j <template.json>
```
- Example

```shell
./summon.sh -h https://closedstack.cernerasp.com -t <closedstack api token> -f ./sample_list.txt
./provision.sh -h https://closedstack.cernerasp.com -t <closedstack api token> -f ./sample_list.txt -j httpfs.json
```
- Additionally you can use the options flag -o along with these options. You can use them in any order and they will follow the order you typed them when making the table.
```
-o iasp
i = ID
a = IP Address
s = Switch/Port
p = Provisioned State
```
- An example would be using -o ia
```
./summon.sh -o ia -h <url> -t <closedstack api token> -f <path to server list>

Output:
 
Serial       ID          IP
FI4390253    fda8dhfsa
FI4320593    asdf8F7da   1.1.1.1
```
- Once ran it will create a timestamped output.csv file that can be opened with excel

- Failures will be logged in a timestamped fail.log file
