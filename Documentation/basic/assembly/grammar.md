# 汇编语法

汇编时钟低级语言，亦称为符号语言。在汇编语言中，用助记符（Mnemonics）代替机器指令的操作码，用地址符号（Symbol）或标号（Label）代替指令或操作数的地址。在不同的设备中，汇编语言对应着不同的机器语言指令集，通过汇编过程转换成机器指令。普遍地说，特定的汇编语言和特定的机器语言指令集是一一对应的,不同平台之间不可直接移植。

## 两种汇编风格差异对比

X86汇编语言风格有两种汇编风格：AT&T 和 Intel 风格。

### 寄存器命名

- AT&T风格中,寄存器会加上%作为前缀
- Intel汇编中寄存器名是不需要加前缀的.可以直接使用.

|AT&T风格|Intel风格|说明|
|----|----|----|
|`push %eax`|`push eax`|这是一条入栈指令,把寄存器`eax`中的值压入栈中|

### 立即数格式

- 在AT&T 汇编中 , 用`$`前缀表示一个立即数.
- 在Intel 汇编中 , 立即数没有任何前缀. 直接用一个数字表示. (当然有不同的进制. 比如 0x01 , 10 等)

|AT&T风格|Intel风格|说明|
|----|----|----|
|`push $1`|`push 1`|把一个立即数压入栈中|

### 操作数顺序

AT&T和Intel格式中的源操作数和目标操作数的位置正好相反，下面是给寄存器`EAX`赋一个初值`1`。

- AT&T风格: 操作符 源操作数 , 目的操作数 `mov $1 , %eax`
- Intel 风格:操作符 目的操作数 , 源操作数 `mov eax , 1`

### 内存操作数的寻址方式

- AT&T寻址格式: `section:disp(base, index, scale)`
- Intel 寻址格式: `section:[base + index*scale + disp]`

无论形式如何，都是实现如下的地址计算：

```
disp + base + index * scale
# 最终地址 = 地址或偏移 + %基址或偏移量寄存器 + %索引寄存器 * 比例因子
```

> 其中base和index必须是寄存器，disp和scale可以是常数

|AT&T格式|Intel格式|
|----|----|
|`movl -4(%ebp), %eax`|`mov eax, [ebp - 4]`|
|`movl array(, %eax, 4), %eax`|`mov eax, [eax*4 + array]`|
|`movw array(%ebx, %eax, 4), %cx`|`mov cx, [ebx + 4*eax + array]`|
|`movb $4, %fs:(%eax)`|`mov fs:eax, 4`|

### 数据宽度表示

- 在AT&T汇编格式中，操作数的字长由操作符的最后一个字母决定，后缀b、w、l分别表示操作数为字节（byte，8比特）、字（word，16比特）和长字（long，32比特）
- 在Intel汇编格式中，操作数的字长是用byte ptr和word ptr等前缀来表示的

### 另附：objdump反汇编

- objdump -d <file(s)>: 将代码段反汇编；
- objdump -S <file(s)>: 将代码段反汇编的同时，将反汇编代码与源代码交替显示，编译时需要使用-g参数，即需要调试信息；
- objdump -C <file(s)>: 将C++符号名逆向解析
- objdump -l <file(s)>: 反汇编代码中插入文件名和行号
- objdump -j section <file(s)>: 仅反汇编指定的section

常用反汇编命令说明：

- 在linux上使用 `objdump -d <file>` 反汇编生成 AT&T 格式的汇编代码
- 在linux上使用 `objdump -d -mi386:x86-64:intel` 反汇编生成 Intel 格式的汇编代码
