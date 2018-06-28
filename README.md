# IbanUtilSwift
___

Swift for [iban4j](https://github.com/arturmkrtchyan/iban4j)

IbanUtilSwift is a Swift library for generation and validation of the International Bank Account Numbers (IBAN ISO_13616).

## Usage

### from iban

	let iban = "XE7338O073KYGTWWZN0F2WZ0R8PX5ZPPZS"
	guard let address = IbanUtil.fromIban(iban: iban) else { return nil }
	//address: 00c5496aee77c1ba1f0854206a26dda82a81d6d8

### to iban

	let address = "00c5496aee77c1ba1f0854206a26dda82a81d6d8"
	let iban = IbanUtil.toIban(address: address)
	//iban: XE7338O073KYGTWWZN0F2WZ0R8PX5ZPPZS

## License

IbanUtilSwift is available under the MIT license. See the LICENSE file for more info.