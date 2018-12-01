package com.squareup.workflow

import okio.Buffer
import okio.BufferedSink
import okio.BufferedSource
import okio.ByteString
import okio.ByteString.encodeUtf8
import java.lang.Float.floatToRawIntBits
import java.lang.Float.intBitsToFloat

/**
 * **NB:** This class is not quite deprecated yet, but it will be _very_ soon.
 *
 * A lazy wrapper of [ByteString]. Allows [ScreenWorkflow]s to capture their state
 * frequently, without worrying about performing unnecessary serialization work.
 */
class Snapshot
private constructor(private val toByteString: () -> ByteString) {

  companion object {
    @JvmField
    val EMPTY = Snapshot.of(ByteString.EMPTY)

    @JvmStatic
    fun of(string: String): Snapshot = Snapshot { ByteString.encodeUtf8(string) }

    @JvmStatic
    fun of(byteString: ByteString): Snapshot = Snapshot { byteString }

    @JvmStatic
    fun of(lazy: () -> ByteString): Snapshot = Snapshot(lazy)

    @JvmStatic
    fun of(integer: Int): Snapshot {
      return Snapshot {
        with(Buffer()) {
          writeInt(integer)
          readByteString()
        }
      }
    }

    /** Create a snapshot by writing to a nice ergonomic [BufferedSink]. */
    @JvmStatic
    fun write(lazy: (BufferedSink) -> Unit): Snapshot = of {
      Buffer().apply(lazy)
          .readByteString()
    }
  }

  @get:JvmName("bytes")
  val bytes: ByteString by lazy { toByteString() }

  /**
   * Returns a `String` describing the [bytes] of this `Snapshot`.
   *
   * **This method forces serialization, calling it may be expensive.**
   */
  override fun toString(): String = "Snapshot($bytes)"

  /**
   * Compares `Snapshot`s by comparing their [bytes].
   *
   * **This method forces serialization, calling it may be expensive.**
   */
  override fun equals(other: Any?) = (other as? Snapshot)?.let { bytes == it.bytes } ?: false

  /**
   * Calculates hashcode using [bytes].
   *
   * **This method forces serialization, calling it may be expensive.**
   */
  override fun hashCode() = bytes.hashCode()
}

fun <T : Any> BufferedSink.writeNullable(
  obj: T?,
  writer: BufferedSink.(T) -> Unit
): BufferedSink = apply {
  writeBooleanAsInt(obj != null)
  obj?.let { writer(it) }
}

fun <T : Any> BufferedSource.readNullable(reader: BufferedSource.() -> T): T? {
  return if (readBooleanFromInt()) reader() else null
}

fun BufferedSink.writeBooleanAsInt(bool: Boolean): BufferedSink = writeInt(if (bool) 1 else 0)

fun BufferedSource.readBooleanFromInt(): Boolean = readInt() == 1

fun BufferedSink.writeFloat(float: Float): BufferedSink = writeInt(floatToRawIntBits(float))

fun BufferedSource.readFloat(): Float = intBitsToFloat(readInt())

fun BufferedSink.writeUtf8WithLength(str: String): BufferedSink {
  return writeByteStringWithLength(encodeUtf8(str))
}

fun BufferedSource.readUtf8WithLength(): String = readByteStringWithLength().utf8()

fun BufferedSink.writeOptionalUtf8WithLength(str: String?): BufferedSink = apply {
  writeNullable(str) { writeUtf8WithLength(it) }
}

fun BufferedSource.readOptionalUtf8WithLength(): String? {
  return readNullable { readUtf8WithLength() }
}

fun BufferedSink.writeByteStringWithLength(bytes: ByteString): BufferedSink = apply {
  writeInt(bytes.size())
      .write(bytes)
}

fun BufferedSource.readByteStringWithLength(): ByteString {
  val size = readInt()
  return readByteString(size.toLong())
}

inline fun <reified T : Enum<T>> BufferedSource.readOptionalEnumByOrdinal(): T? {
  return readNullable { readEnumByOrdinal<T>() }
}

fun <T : Enum<T>> BufferedSink.writeOptionalEnumByOrdinal(enumVal: T?): BufferedSink {
  return writeNullable(enumVal) { writeEnumByOrdinal(it) }
}

inline fun <reified T : Enum<T>> BufferedSource.readEnumByOrdinal(): T {
  return T::class.java.enumConstants[readInt()]
}

fun <T : Enum<T>> BufferedSink.writeEnumByOrdinal(enumVal: T): BufferedSink {
  return writeInt(enumVal.ordinal)
}

fun <T> BufferedSink.writeList(
  values: List<T>,
  writer: BufferedSink.(T) -> Unit
): BufferedSink = apply {
  writeInt(values.size)
  values.forEach { writer(it) }
}

fun <T> BufferedSource.readList(
  reader: BufferedSource.() -> T
): List<T> = List(readInt()) { reader() }

/**
 * Runs `block` with a `BufferedSource` that will read from this `ByteString`.
 *
 * Lets you do stuff like:
 * ```
 *   myBlob.parse {
 *     MyValueObject(
 *       name = it.readUtf8WithLength(),
 *       age = it.readInt()
 *     )
 *   }
 * ```
 */
inline fun <T> ByteString.parse(block: (BufferedSource) -> T): T = block(Buffer().write(this))
