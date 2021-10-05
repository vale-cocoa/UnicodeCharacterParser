# UnicodeCharacterParser

Parse a sequence of `Character` from a stream of bytes via `UnicodeCodec`.

`UnicodeCharacterParser` is a value type conforming to `IteratorProtocol`, whose `Element` type is `Character` and generic over its `Codec` type which has to conform to `UnicodeCodec` protocol.

You can create new instances chosing between its two initializers: 
* `init?(streamingBytesAt)`: this failable initializer accepts as its parameter an `URL` instance. If an `InputStream` can be obtained from the specified url parameter, then it returns a new instance ready to iterate the sequence of `Character` obtainable from the bytes streamed at such url. Otherwise, in case it wasn't possible to obtain an `InputStream` from the specified url parameter, it returns `nil`. 
* `init(streamingBytesFrom:)`: this initializer accepts a `Data` parameter, which is used to create the `InputStream` from which bytes are pulled an then coded into `Character` elements.

Once you've created a new instance, you obtain `Character` instances in sequence by using the mutating method `next()`, as you would with any other iterator.
This operation is done by buffering a certain amount of bytes from the stream, attempt to bind them to the memory alignment for the `CodeUnit` of the `UnicodeCodec` type associated to the parser instance, and then using such codec to decode the unicode scalar(s) value(s) for the character to return.
For example when the associated `UnicodeCodec` type is `UTF32`, each time 4 bytes from the stream are pulled and aligned into a `UInt32` value —that is the `CodeUnit` type associated to `UTF32` codec— which is then passed as code unit to the codec for decoding a unicode scalar value. 
If instead the associated codec is `UTF8`, then each byte from the stream is used as `UInt8` value —that is the `CodeUnit` type asscoated to `UTF8` codec— and passed to the codec to decode a unicode scalar (`UTF8` codec might then use up to 4 bytes in sequence to decode certain unicode scalar).

When the associated codec finds an error while decoding code unit values into unicode scalars, then a replacement character is returned. That would be the corresponding decoded character from to the `encodedReplacementCharacter` static value of the associated `UnicodeCodec`; for example if the `UnicodeCodec` associated to the parser is `UTF8`, then the replacement character would be `U+FFFD`: &#xFFFD;

After all elements of the iterator are consumed —that is when `next()` method has returned a `nil` value—, you might also check for any error that could have happened during the streaming of bytes or if the stream has ended with a truncated code unit value.

