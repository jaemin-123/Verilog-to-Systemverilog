## Verilog 예제 공통 Makefile 사용 플로우 정리

이 문서는 공통 `Makefile` 하나로 Verilog 예제들을

> **시뮬레이션(xsim/msim) → 합성 → 구현+비트스트림 → 결과 수집**

까지 실행하는 방법을 정리한 것이다.

---

## 0. 기본 개념

각 예제는 `EX` 라는 변수로 선택해서 실행한다.

- 예: `EX=examples/gate` 또는 `EX=gate`  
- 예제 폴더 안에 있는 `.v`, `tb_*.v`, `.xdc` 등을 자동으로 찾아서 사용한다.

---

## 1. 예제 디렉터리 구조 & 자동 추론

### 1.1 예제 폴더 구조 (예시)

```text
.
├─ Makefile
├─ xsim.tcl
├─ synth.tcl
├─ bit.tcl
├─ run.do
└─ examples/
   ├─ gate/
   │   ├─ gates.v       # DUT
   │   ├─ tb_gates.v    # testbench (tb_*.v 규칙)
   │   └─ gate.xdc      # (선택) Basys3 등 보드용 XDC
   ├─ alu/
   │   ├─ alu.v
   │   ├─ tb_alu.v
   │   └─ alu.xdc
   └─ ...
```

### 1.2 Makefile이 자동으로 추론하는 변수들

```make
RTL  ?= $(EX)/*.v                      # 설계 + TB 포함 Verilog
TB   ?= $(firstword $(wildcard $(EX)/tb_*.v))
TOP  ?= $(notdir $(basename $(TB)))    # tb_gates.v -> tb_gates
XDC  ?= $(EX)/*.xdc
PART ?= xc7a35tcpg236-1                # 기본 Basys3
OUT  ?= build/$(notdir $(EX))          # 결과 폴더 (예: build/gate)
DUT  ?=                                # 합성/비트스트림용 최상위 모듈명
```

- `TB` 를 기준으로 **testbench 이름(TOP)** 을 자동 추출한다.
- `DUT` 는 **합성/비트스트림 시 Top 모듈** 이름이라 반드시 지정해줘야 한다.
- 예제 폴더 안에 `example.mk` 를 두고 `DUT`, `PART` 등을 덮어쓸 수 있다.

---

## 2. 시뮬레이션 플로우

### 2.1 Vivado xsim

```bash
make xsim EX=examples/gate
# 또는
make xsim EX=gate
```

- 동작:
  - `EX/*.v` 와 `EX/tb_*.v` 를 찾아서
  - `xsim.tcl`을 이용해 Vivado xsim으로 시뮬레이션 수행
- 내부 형태(개념):
  ```bash
  vivado -mode tcl -source xsim.tcl -tclargs "<RTL들>" "<TB>" <TOP>
  ```

### 2.2 ModelSim / Questa (vsim)

```bash
make msim EX=examples/gate           # VSIM이 PATH에 있으면
make msim EX=examples/gate VSIM=vsim # 명시적으로 지정 가능
```

- 동작:
  - `run.do` 스크립트를 사용해서 컴파일 + vsim -c 실행
- 내부에서는 DO 스크립트가
  - `vlog $(RTL)` / `vlog $(TB)`
  - `vsim -c $(TOP)`
  를 수행하는 구조(예상).

> `EX` 를 빼먹으면 Makefile이  
> `Set EX=<example_dir> e.g., EX=gate` 라고 에러를 내고 종료한다.

---

## 3. 합성 / 구현 플로우 (Vivado)

### 3.1 합성만 수행 (synth)

```bash
make synth EX=examples/gate DUT=gates
# 보드를 바꾸고 싶으면
make synth EX=examples/gate DUT=gates PART=xc7a100tcsg324-1
```

- 필수:
  - `EX` : 예제 폴더
  - `DUT` : Top 모듈명 (예: `gates`)
- 옵션:
  - `PART` : 디폴트는 `xc7a35tcpg236-1` (Basys3)
  - `XDC`  : 기본은 `$(EX)/*.xdc`
  - `OUT`  : 기본은 `build/$(notdir $(EX))`

내부적으로:

```bash
vivado -mode batch -source synth.tcl   -tclargs $(DUT) $(PART) "$(RTL)" "$(XDC)" "$(OUT)"
```

결과:
- `OUT` 폴더 아래에 합성 리포트(`util_*.rpt`, `timing_*.rpt`)와 DCP/netlist 생성.

---

### 3.2 구현 + 비트스트림 생성 (bit)

```bash
make bit EX=examples/gate DUT=gates
```

- 합성과 동일하게 `EX`, `DUT` 필요.
- 필요하다면 `PART`, `XDC`, `OUT` 도 동일 방식으로 덮어쓰기 가능.

내부적으로:

```bash
vivado -mode batch -source bit.tcl   -tclargs $(DUT) $(PART) "$(RTL)" "$(XDC)" "$(OUT)"
```

결과:
- `OUT` 폴더에 `*.bit`, `*.ltx`, `*.dcp` 등 생성.

---

## 4. 결과 정리 (harvest) & 청소 (clean)

### 4.1 결과 모으기 – `harvest`

```bash
make harvest EX=examples/gate
```

- 기본 저장 위치: `artifacts/<예제이름>/`
  - 예: `EX=examples/gate` → `artifacts/gate/`

폴더 구조:

```text
artifacts/gate/
├─ sim/    # wdb, vcd 등 파형 파일
├─ rpt/    # util_*.rpt, timing_*.rpt, drc*.rpt ...
└─ impl/   # *.bit, *.ltx, *.dcp
```

하는 일:

- 현재 디렉터리와 `OUT` 또는 `build` 아래를 검색해서
  - `*.wdb`, `sim.vcd` → `sim/`
  - `*.bit`, `*.ltx`, `*.dcp` → `impl/`
  - `util_*.rpt`, `timing_*.rpt`, `drc*.rpt`, `reports/*.rpt` → `rpt/`
- 마지막에 `Saved → artifacts/<예제>` 메시지 출력

즉, **발표·보고용 결과만 따로 모으는 타깃**이다.

---

### 4.2 깨끗하게 지우기 – `clean`

```bash
make clean
```

삭제 대상:

- `build/`
- Vivado 관련: `*.log`, `*.jou`, `*.pb`, `xsim.dir`, `.Xil`, `.xil`
- ModelSim 관련: `work/`, `transcript`, `vsim.wlf`, `*.wlf`

> `artifacts/`는 지우지 않기 때문에, 결과 모아둔 곳은 그대로 남는다.

---

## 5. 새 예제 추가할 때 체크리스트

1. `examples/<이름>/` 폴더 만들기  
2. RTL 파일(`*.v`)과 testbench(`tb_*.v`) 넣기  
3. (보드 타깃이면) XDC 파일 1개 추가  
4. Top 모듈 이름이 DUT와 testbench에서 일치하는지 확인  
5. 필요하면 `examples/<이름>/example.mk` 작성:
   ```make
   DUT  = <top_module_name>
   PART = xc7a35tcpg236-1
   ```
6. 아래 명령으로 테스트:
   ```bash
   make xsim    EX=examples/<이름>
   make synth   EX=examples/<이름> DUT=<top>
   make bit     EX=examples/<이름> DUT=<top>
   make harvest EX=examples/<이름>
   ```

이 파일은 README나 `doc/flow.md`에 그대로 복사해서 사용할 수 있는 형태로 작성되었다.
