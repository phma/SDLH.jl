# Shamir Discrete Logarithm Hash
This is an implementation (in progress) of the Shamir Discrete Logarithm Hash. It generates an RSA key and hashes a message by exponentiating the generator of the group, using the message as the exponent.

This is not intended for serious cryptography, for the following reasons:

- Given any message, it is trivial to produce a hash collision by prepending a null byte.

- Anyone in possession of the secret key can produce a hash collision by adding the totient to a message.

- Anyone in possession of a public key and a hash collision other than prepending null bytes can produce more hash collisions and factor the modulus.

- It's much slower than the hash functions that split a message in blocks and feed them to a compression function.
