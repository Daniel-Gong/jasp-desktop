#ifndef DATAINFORECORD_H
#define DATAINFORECORD_H

#include "systemfileformat.h"
#include "readablerecord.h"
#include "debug_cout.h"
#include "stringutils.h"

namespace spss
{

template <RecordSubTypes subType>
class DataInfoRecord : public ReadableRecord<rectype_meta_data>
{
public:

	DataInfoRecord(const HardwareFormats &fixer, RecordSubTypes fileSubType, RecordTypes fileType, SPSSStream &from)
		: ReadableRecord<rectype_meta_data>(fixer, fileType, from)
	{
		if (fileSubType != SUB_RECORD_TYPE)
		{
			DEBUG_COUT5("DataInfoRecord of type ", SUB_RECORD_TYPE, " was passed record type ", fileSubType, ".");
			throw std::runtime_error("SPSS record sub type mismatch.");
		}
		// Read the file values.
		SPSSIMPORTER_READ_MEMBER(size, from, fixer);
		SPSSIMPORTER_READ_MEMBER(count, from, fixer);
	}

	DataInfoRecord(RecordSubTypes fileSubType, RecordTypes fileType)
		: ReadableRecord<rectype_meta_data>(fileType)
		, _size(8)
		, _count(3)
	{
		if (fileSubType != SUB_RECORD_TYPE)
		{
			DEBUG_COUT5("DataInfoRecord of type ", SUB_RECORD_TYPE, " was passed record type ", fileSubType, ".");
			throw std::runtime_error("SPSS record sub type mismatch.");
		}
	}


	// All these type have both szie and count values.
	SPSSIMPORTER_READ_ATTRIB(int32_t, size)
	SPSSIMPORTER_READ_ATTRIB(int32_t, count)

public:
	/**
	 * @brief process Manipulates columns by adding the contents of thie record.
	 * @param columns
	 *
	 * Implematations should examine columns to determine the record history.
	 */
	virtual void process(SPSSColumns & columns) = 0;

	static const RecordSubTypes SUB_RECORD_TYPE = subType;

protected:

	typedef std::map<std::string, std::string> Tuples;

	/**
	 * @brief breakNamePairs Breaks tab separated name=value pairs to a map.
	 * @param fromFile The instring (from record).
	 * @param seps The separator between tuples (name / value pair)
	 * @return Map of values keyed by name.
	 */
	Tuples breakNamePairs(const std::string &fromFile, const char &separator = '\011');


};

/*
 * Implmementation of  DataInfoRecord::breakNamePairs().
 */
template <RecordSubTypes subType>
std::map<std::string, std::string> DataInfoRecord<subType>::breakNamePairs(const std::string &fromFile, const char &separator)
{
	std::map<std::string, std::string> result;
	bool pastEqu = false;
	std::string value;
	std::string name;
	for (std::string::const_iterator sI = fromFile.begin(); sI != fromFile.end(); sI++)
	{
		const char c = *sI;
//		DEBUG_COUT5("DataInfoRecord::breakNamePairs found char : ", static_cast<int>(c), " (", ((c >= ' ') ? c : '.'), ")." );
		if (c == 0)
			continue;
		else if (c == '=')
			pastEqu = true;

		else if(c == separator)
		{
			// Save the name value pairs found.
			result.insert(std::pair<std::string, std::string>(StrUtils::rTrimWS(name), value));
			// clear.
			name = std::string();
			value = std::string();
			pastEqu = false;
		}

		else
		{
			if (pastEqu)
				value.push_back(c);
			else
				name.push_back(c);
		}
	}

	// Save the last unterminated value (if any)
	if (name.length() > 0)
		result.insert(std::pair<std::string, std::string>(name, value));

	return result;
}

}

#endif // DATAINFORECORD_H
