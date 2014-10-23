package gen

import "fmt"

type implInfo struct {
	path        string
	method      string
	implemented bool
}

var implList []implInfo

func addImplDef(path, method string) {
	implList = append(implList, implInfo{
		path:   path,
		method: method,
	})
}

func markImpl(path, method string) {
	for i, impl := range implList {
		if impl.method == method && impl.path == path {
			impl.implemented = true
			implList[i] = impl
		}
	}
}

func PrintImplementSummary() {
	for _, impl := range implList {
		if impl.implemented {
			fmt.Print("o ")
		} else {
			fmt.Print("- ")
		}
		fmt.Printf("%-8s", impl.method)
		fmt.Println(impl.path)
	}
}
