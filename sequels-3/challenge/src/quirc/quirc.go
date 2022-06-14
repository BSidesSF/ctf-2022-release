package quirc

/*
#cgo LDFLAGS: -L./quirc -lquirc -lm
#include "quirc/lib/quirc.h"
*/
import "C"

import (
	"errors"
	"fmt"
	"image"
	"image/color"
	"unsafe"
)

type QuircError struct {
	msg string
}

func (e QuircError) Error() string {
	return e.msg
}

var (
	QuircErrorAllocate = QuircError{"Error allocating"}
	QuircSizeError     = QuircError{"Error in sizing"}
	QuircInternalError = QuircError{"Internal error in Quirc"}
	QuircNoCode        = QuircError{"No QR Code Found"}
	NoMorePixels       = errors.New("No More Pixels")
)

type PixelIterator struct {
	x   int
	y   int
	img image.Image
}

func NewPixelIterator(img image.Image) *PixelIterator {
	return &PixelIterator{
		img: img,
		x:   img.Bounds().Min.X,
		y:   img.Bounds().Min.Y,
	}
}

func (pi *PixelIterator) Next() (color.Color, error) {
	if pi.x >= pi.img.Bounds().Max.X {
		pi.y++
		pi.x = pi.img.Bounds().Min.X
		if pi.y >= pi.img.Bounds().Max.Y {
			return nil, NoMorePixels
		}
	}
	rv := pi.img.At(pi.x, pi.y)
	pi.x++
	return rv, nil
}

func (pi *PixelIterator) NextGray() (uint8, error) {
	if px, err := pi.Next(); err != nil {
		return uint8(0), err
	} else {
		return color.GrayModel.Convert(px).(color.Gray).Y, nil
	}
}

func QuircDecode(img image.Image) ([]byte, error) {
	// Create and allocate the buffer
	var qrdec *C.struct_quirc
	qrdec = C.quirc_new()
	if qrdec == nil {
		return nil, QuircErrorAllocate
	}
	defer func() {
		C.quirc_destroy(qrdec)
	}()
	w := img.Bounds().Max.X - img.Bounds().Min.X
	h := img.Bounds().Max.Y - img.Bounds().Min.Y
	if rc := C.quirc_resize(qrdec, C.int(w), C.int(h)); int(rc) != 0 {
		return nil, QuircErrorAllocate
	}

	// Copy in image data
	var bufPtr *C.uchar
	var wBuf C.int
	var hBuf C.int
	bufPtr = C.quirc_begin(qrdec, &wBuf, &hBuf)
	if int(wBuf) < w || int(hBuf) < h {
		return nil, QuircInternalError
	}
	imgSlice := unsafe.Slice(bufPtr, int(wBuf)*int(hBuf))
	it := NewPixelIterator(img)
	for i := 0; i < w*h; i++ {
		v, err := it.NextGray()
		if err != nil {
			return nil, fmt.Errorf("Unexpected error getting gray values: %w", err)
		}
		imgSlice[i] = C.uchar(v)
	}
	C.quirc_end(qrdec)

	// Decode steps
	if nc := C.quirc_count(qrdec); int(nc) == 0 {
		// No code found!
		return nil, QuircNoCode
	}

	// For now, we only deal with the first code found
	var code C.struct_quirc_code
	var data C.struct_quirc_data
	C.quirc_extract(qrdec, C.int(0), &code)
	errno := C.quirc_decode(&code, &data)
	if int(errno) != 0 {
		return nil, QuircError{C.GoString(C.quirc_strerror(errno))}
	}
	rv := C.GoBytes(unsafe.Pointer(&data.payload[0]), data.payload_len)
	return rv, nil
}
