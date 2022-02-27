package util

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
)

func SortFile(file string) {
	lines, err := ReadLines(file)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	sort.Strings(lines)
	err = WriteLines(file, lines)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func ReadLines(file string) (lines []string, err error) {
	f, err := os.Open(file)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	r := bufio.NewReader(f)
	for {
		const delim = '\n'
		line, err := r.ReadString(delim)
		if err == nil || len(line) > 0 {
			if err != nil {
				line += string(delim)
			}
			lines = append(lines, line)
		}
		if err != nil {
			if err == io.EOF {
				break
			}
			return nil, err
		}
	}
	return lines, nil
}

func WriteLines(file string, lines []string) (err error) {
	f, err := os.Create(file)
	if err != nil {
		return err
	}
	defer f.Close()
	w := bufio.NewWriter(f)
	defer w.Flush()
	for _, line := range lines {
		_, err := w.WriteString(line)
		if err != nil {
			return err
		}
	}
	return nil
}

func CmdExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

func ExecWd() (string, error) {
	ex, err := os.Executable()
	if err != nil {
		return "", err
	}

	exPath := filepath.Dir(ex)
	return exPath, err
}
