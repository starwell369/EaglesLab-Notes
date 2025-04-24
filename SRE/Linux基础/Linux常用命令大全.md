# gzip/unzip
```shell
Usage: gzip [OPTION]... [FILE]...
Compress or uncompress FILEs (by default, compress FILES in-place).

Usage: unzip [-Z] [-opts[modifiers]] file[.zip] [list] [-x xlist] [-d exdir]
  Default action is to extract files in list, except those in xlist, to exdir;
  file[.zip] may be a wildcard.  -Z => ZipInfo mode ("unzip -Z" for usage).
```

**常用案例**
```shell
# 压缩后保留原文件
gzip -k <filename>
# 递归压缩目录内所有文件
gzip -r <dir>
# 压缩级别设置: -1（最快）到 -9（最高压缩比），默认 -6
gzip -k -1 <filename>
# 流式压缩（处理大文件）：边读边压缩
cat <filename> | gzip > <filename>.gz

# 解压到指定目录
unzip file.zip -d /target/path
# 列出压缩包内容
unzip -l file.zip
# 强制覆盖/保留已有文件
unzip -o file.zip
unzip -n file.zip
```

# tar
```shell
Usage: tar [OPTION...] [FILE]...
GNU 'tar' saves many files together into a single tape or disk archive, and can
restore individual files from the archive.
```

**常用案例**
```shell
# 打包目录 & 打包并压缩目录
tar -cvf archive.tar /path/to/directory
tar -zcvf <dir_name>.tar.gz <dir>
# 解压普通归档 & gzip压缩包 & 指定目录
tar -xvf archive.tar
tar -xzvf backup.tar.gz
tar -xzvf backup.tar.gz -C /target/path
# 查看归档内容
tar -tvf archive.tar
tar -tzvf backup.tar.gz
```

# wget
```shell
Usage: wget [OPTION]... [URL]...
```

**常用案例**
```shell
# 下载单个文件并重命名保存
wget -O custom_name.zip http://example.com/download.php?id=1080
# 断点续传
wget -c http://example.com/largefile.iso
# 限速下载
wget --limit-rate=500k http://example.com/data.tar.gz

```

# curl
```shell
Usage: curl [options...] <url>
```

**常用案例**
```shell
# 保存响应
curl -o output.html http://example.com 
curl -O http://example.com/file.zip
# 调试与日志
curl -v http://example.com
curl -i http://example.com
```