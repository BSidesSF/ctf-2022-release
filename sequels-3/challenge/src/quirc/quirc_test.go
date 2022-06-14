package quirc

import (
	"bytes"
	"image"
	"os"
	"path/filepath"
	"testing"

	_ "image/png"
)

func testQuircSingle(t *testing.T, fname string, exp []byte) {
	fp, err := os.Open(fname)
	if err != nil {
		t.Fatalf("Unable to open %s: %v", fname, err)
		return
	}
	defer fp.Close()
	img, _, err := image.Decode(fp)
	if err != nil {
		t.Fatalf("Unable to decode %s: %v", fname, err)
		return
	}
	rv, err := QuircDecode(img)
	if err != nil {
		t.Fatalf("Error with QuircDecode from %s: %v", fname, err)
		return
	}
	if !bytes.Equal(rv, exp) {
		t.Fatalf("Error in decode, got %q, expected %q", rv, exp)
		return
	}
}

func TestQuircBasic(t *testing.T) {
	testdata := []struct {
		fname string
		data  []byte
	}{
		{"hello_world.png", []byte("hello world")},
		{"hello_world2.png", []byte("hello world!!")},
		{"hello_world3.png", []byte("hello world?")},
	}
	for _, d := range testdata {
		testQuircSingle(t, filepath.Join("testdata", d.fname), d.data)
	}
}
