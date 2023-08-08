# LITERALS

urQL supports most of the aura types implemented in Urbit as literals for the INSERT and SELECT commands. The *loobean* Urbit literal types is supported by *different* literals in urQL than normally in Urbit. urQL supports some literal types in multiple ways. Dates, timespans, and ships can all be represented in INSERT without the leading **~**. Unsigned decimal can be represented without the dot thousands separator. In some cases the support between INSERT and SELECT is not the same.

Column types (auras) not supported for INSERT can only be inserted into tables through the API.

| Aura |     Description      |     INSERT         |     SELECT         |
| :--- |:-------------------- |:------------------:|:------------------:|
| @c   | UTF-32               | ~-~45fed. | **not supported** |
| @da  | date                 | ~2020.12.25 | ~2020.12.25 |
|      |                      | ~2020.12.25..7.15.0 | ~2020.12.25..7.15.0 |
|      |                      | ~2020.12.25..7.15.0..1ef5 | ~2020.12.25..7.15.0..1ef5 |
|      |                      | 2020.12.25 | 2020.12.25 |
|      |                      | 2020.12.25..7.15.0 | 2020.12.25..7.15.0 |
|      |                      | 2020.12.25..7.15.0..1ef5 | 2020.12.25..7.15.0..1ef5 
| @dr  | timespan             | ~d71.h19.m26.s24..9d55 | ~d71.h19.m26.s24..9d55 |
|      |                      | ~d71.h19.m26.s24 | ~d71.h19.m26.s24 |
|      |                      | ~d71.h19.m26 | ~d71.h19.m26 |
|      |                      | ~d71.h19 | ~d71.h19 |
|      |                      | ~d71 | ~d71 |
|      |                      | d71.h19.m26.s24..9d55 |  |
|      |                      | d71.h19.m26.s24 |  |
|      |                      | d71.h19.m26 |  |
|      |                      | d71.h19 |  |
|      |                      | d71 |  |
| @f   | loobean              | y, n, Y, N | Y, N |
| @if  | IPv4 address         | .195.198.143.90 | .195.198.143.90 |
| @is  | IPv6 address         | .0.0.0.0.0.1c.c3c6.8f5a | .0.0.0.0.0.1c.c3c6.8f5a |
| @p   | ship name            | ~sampel-palnet | ~sampel-palnet |
|      |                      | sampel-palnet  |  |
| @q   | phonemic base        | **not supported** | **not supported** |
| @rh  | half float (16b)     | **not supported** | **not supported** |
| @rs  | single float (32b)   | .3.14, .-3.14 | .3.14, .-3.14 |
| @rd  | double float (64b)   | ~3.14, ~-3.14 | ~3.14, ~-3.14 |
| @rq  | quad float (128b)    | **not supported** | **not supported** |
| @sb  | signed binary        | --0b10.0000 | --0b10.0000 |
|      |                      | -0b10.0000 | -0b10.0000 |
| @sd  | signed decimal       | --20, -20 | --20, -20 |
| @sv  | signed base32        | --0v201.4gvml.245kc | --0v201.4gvml.245kc |
|      |                      | -0v201.4gvml.245kc | -0v201.4gvml.245kc |
| @sw  | signed base64        | --0w2.04AfS.G8xqc | --0w2.04AfS.G8xqc |
|      |                      | -0w2.04AfS.G8xqc | -0w2.04AfS.G8xqc |
| @sx  | signed hexadecimal   | --0x2004.90fd | --0x2004.90fd |
|      |                      | -0x2004.90fd | -0x2004.90fd |
| @t   | UTF-8 text (cord)    | 'cord', 'cord\\\\'s' <sup>1</sup> | 'cord', 'cord\\\\'s' <sup>1</sup> |
| @ta  | ASCII text (knot)    | *support pending* | *support pending* |
| @tas | ASCII text (term)    | *support pending* | *support pending* |
| @ub  | unsigned binary      | 10.1011 | 10.1011 |
| @ud  | unsigned decimal     | 2.222 | 2.222 |
|      |                      | 2222 | 2222 |
| @uv  | unsigned base32      | **not supported** | **not supported** |
| @uw  | unsigned base64      | e2O.l4Xpm | **not supported** |
| @ux  | unsigned hexadecimal | 0x12.6401 | 0x12.6401 |

 <sup>1</sup> Example of embedding single quote in @t literal.
