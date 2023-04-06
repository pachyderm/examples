package main

import (
    "bufio"
    "flag"
    "fmt"
    "log"
    "os"
    "sort"
    "path/filepath"
)

func main() {
    mode := flag.String("mode", "split", "Specify mode: split or combine")
    input := flag.String("input", "", "Specify input file or folder")
    output := flag.String("output", "", "Specify output folder or file")
    lineCount := flag.Int("linecount", 0, "Specify number of lines per file in split mode")

    flag.Parse()

    if *mode == "split" {
        if *lineCount == 0 {
            log.Fatal("Line count must be provided in split mode")
        }
        if *input == "" {
            log.Fatal("Input file must be provided in split mode")
        }
        if *output == "" {
            log.Fatal("Output folder must be provided in split mode")
        }

        err := walkDirToSplit(*input, *output, *lineCount)
        if err != nil {
            log.Fatal(err)
        }
    } else if *mode == "combine" {
        if *input == "" {
            log.Fatal("Input folder must be provided in combine mode")
        }
        if *output == "" {
            log.Fatal("Output file must be provided in combine mode")
        }

        err := combineFiles(*input, *output)
        if err != nil {
            log.Fatal(err)
        }
    } else {
        log.Fatal("Invalid mode specified. Must be split or combine")
    }

}

func splitFileNameAndExt(filePath string) (string, string) {
    fileExt := filepath.Ext(filePath)
    fileName := filepath.Base(filePath[:len(filePath)-len(fileExt)])
    return fileName, fileExt
}

func walkDirToSplit(path string, outputFolder string, lineCount int) error {
        files, err := getFileListDir(path)
        if err != nil {
            return err
        }
        for _, file := range files {
            splitFile(file, outputFolder, lineCount)
        }
        return nil
    }

func getFileListDir(path string)([]string, error) {
    var files []string
    err := filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
        if err != nil {
            return err
        }
        if !info.IsDir() {
            files = append(files, path)
        }
        return nil
    })
    if err != nil {
        return nil, err
    }
    sort.Strings(files)
    return files, nil
}


func splitFile(inputFile string, outputFolder string, lineCount int) error {
    f, err := os.Open(inputFile)
    outputfilename, outputext := splitFileNameAndExt(inputFile)
    if err != nil {
        return err
    }
    defer f.Close()

    scanner := bufio.NewScanner(f)

    var lines []string
    fileNum := 1

    for scanner.Scan() {
        lines = append(lines, scanner.Text())

        if len(lines) >= lineCount {
            outputFile := filepath.Join(outputFolder, fmt.Sprintf("%s-%d%s", outputfilename, fileNum, outputext))
            err := writeLinesToFile(outputFile, lines)
            if err != nil {
                return err
            }

            lines = nil
            fileNum++
        }
    }

    if len(lines) > 0 {
        outputFile := filepath.Join(outputFolder, fmt.Sprintf("%s-%d.%s", outputfilename, fileNum, outputext))
        err := writeLinesToFile(outputFile, lines)
        if err != nil {
            return err
        }
    }

    return nil
}

func writeLinesToFile(outputFile string, lines []string) error {
    f, err := os.Create(outputFile)
    if err != nil {
        return err
    }
    defer f.Close()

    w := bufio.NewWriter(f)
    for _, line := range lines {
        fmt.Fprintln(w, line)
    }
    return w.Flush()
}

func combineFiles(inputFolder string, outputFile string) error {
    f, err := os.Create(outputFile)
    if err != nil {
        return err
    }
    defer f.Close()
    files, err := getFileListDir(inputFolder)
    if err != nil {
        return err
    }
    fmt.Println(files)
    for _, file := range files {
        data, err := os.Open(file)
        if err != nil {
            return err
        }
        defer data.Close()
        scanner := bufio.NewScanner(data)
        for scanner.Scan() {
            fmt.Fprintln(f, scanner.Text())
        }

        if err := scanner.Err(); err != nil {
            return err
        }
    }
    if err != nil {
        return err
    }

    return nil
}
