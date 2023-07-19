# Tiny Kernel

<hr/>

<a href='https://tiny-kernel.readthedocs.io/zh_CN/latest/?badge=latest'>
    <img src='https://readthedocs.org/projects/tiny-kernel/badge/?version=latest' alt='Documentation Status' />
</a>


> 期望实现一个最小的内核
    

## 依赖环境说明

|环境|说明|
|---|---|
|sphinx|用于生成文档|
|myst-parser|用于生成文档(markdown语法支持)|
|sphinx-rtd-theme|用于生成文档(主题)|

## 实验方法

1. 编译
```shell
make -j4
```

2. 使用bochs虚拟机运行
```shell
bochs -f ./bochsrc.bxrc
```
