package main

import (
	"fmt"
	"image"
	"os"

	_ "image/jpeg"
	_ "image/png"

	"github.com/bsidessf/ctf-2022/sequels/quirc"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Printf("Usage: %s FILE\n", os.Args[0])
		return
	}
	if fp, err := os.Open(os.Args[1]); err != nil {
		fmt.Printf("Open failed: %v", err)
	} else {
		defer fp.Close()
		img, _, err := image.Decode(fp)
		if err != nil {
			fmt.Printf("Decode failed: %v", err)
			return
		}
		if rv, err := quirc.QuircDecode(img); err != nil {
			fmt.Printf("Error decoding: %v", err)
		} else {
			fmt.Printf("%s: %s", os.Args[1], rv)
		}
	}
}
