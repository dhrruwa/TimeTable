// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_entities.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTimetableDocEntityCollection on Isar {
  IsarCollection<TimetableDocEntity> get timetableDocEntitys =>
      this.collection();
}

const TimetableDocEntitySchema = CollectionSchema(
  name: r'TimetableDocEntity',
  id: -2764336603298551277,
  properties: {
    r'json': PropertySchema(
      id: 0,
      name: r'json',
      type: IsarType.string,
    )
  },
  estimateSize: _timetableDocEntityEstimateSize,
  serialize: _timetableDocEntitySerialize,
  deserialize: _timetableDocEntityDeserialize,
  deserializeProp: _timetableDocEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _timetableDocEntityGetId,
  getLinks: _timetableDocEntityGetLinks,
  attach: _timetableDocEntityAttach,
  version: '3.1.0+1',
);

int _timetableDocEntityEstimateSize(
  TimetableDocEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.json.length * 3;
  return bytesCount;
}

void _timetableDocEntitySerialize(
  TimetableDocEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.json);
}

TimetableDocEntity _timetableDocEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TimetableDocEntity();
  object.id = id;
  object.json = reader.readString(offsets[0]);
  return object;
}

P _timetableDocEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _timetableDocEntityGetId(TimetableDocEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _timetableDocEntityGetLinks(
    TimetableDocEntity object) {
  return [];
}

void _timetableDocEntityAttach(
    IsarCollection<dynamic> col, Id id, TimetableDocEntity object) {
  object.id = id;
}

extension TimetableDocEntityQueryWhereSort
    on QueryBuilder<TimetableDocEntity, TimetableDocEntity, QWhere> {
  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TimetableDocEntityQueryWhere
    on QueryBuilder<TimetableDocEntity, TimetableDocEntity, QWhereClause> {
  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimetableDocEntityQueryFilter
    on QueryBuilder<TimetableDocEntity, TimetableDocEntity, QFilterCondition> {
  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'json',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'json',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'json',
        value: '',
      ));
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterFilterCondition>
      jsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'json',
        value: '',
      ));
    });
  }
}

extension TimetableDocEntityQueryObject
    on QueryBuilder<TimetableDocEntity, TimetableDocEntity, QFilterCondition> {}

extension TimetableDocEntityQueryLinks
    on QueryBuilder<TimetableDocEntity, TimetableDocEntity, QFilterCondition> {}

extension TimetableDocEntityQuerySortBy
    on QueryBuilder<TimetableDocEntity, TimetableDocEntity, QSortBy> {
  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterSortBy>
      sortByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterSortBy>
      sortByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }
}

extension TimetableDocEntityQuerySortThenBy
    on QueryBuilder<TimetableDocEntity, TimetableDocEntity, QSortThenBy> {
  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterSortBy>
      thenByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QAfterSortBy>
      thenByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }
}

extension TimetableDocEntityQueryWhereDistinct
    on QueryBuilder<TimetableDocEntity, TimetableDocEntity, QDistinct> {
  QueryBuilder<TimetableDocEntity, TimetableDocEntity, QDistinct>
      distinctByJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'json', caseSensitive: caseSensitive);
    });
  }
}

extension TimetableDocEntityQueryProperty
    on QueryBuilder<TimetableDocEntity, TimetableDocEntity, QQueryProperty> {
  QueryBuilder<TimetableDocEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TimetableDocEntity, String, QQueryOperations> jsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'json');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCommunityTimetableEntityCollection on Isar {
  IsarCollection<CommunityTimetableEntity> get communityTimetableEntitys =>
      this.collection();
}

const CommunityTimetableEntitySchema = CollectionSchema(
  name: r'CommunityTimetableEntity',
  id: 8198211120396584066,
  properties: {
    r'branch': PropertySchema(
      id: 0,
      name: r'branch',
      type: IsarType.string,
    ),
    r'creatorId': PropertySchema(
      id: 1,
      name: r'creatorId',
      type: IsarType.string,
    ),
    r'creatorName': PropertySchema(
      id: 2,
      name: r'creatorName',
      type: IsarType.string,
    ),
    r'json': PropertySchema(
      id: 3,
      name: r'json',
      type: IsarType.string,
    ),
    r'matchKey': PropertySchema(
      id: 4,
      name: r'matchKey',
      type: IsarType.string,
    ),
    r'section': PropertySchema(
      id: 5,
      name: r'section',
      type: IsarType.string,
    ),
    r'semester': PropertySchema(
      id: 6,
      name: r'semester',
      type: IsarType.string,
    ),
    r'university': PropertySchema(
      id: 7,
      name: r'university',
      type: IsarType.string,
    ),
    r'updatedAtMs': PropertySchema(
      id: 8,
      name: r'updatedAtMs',
      type: IsarType.long,
    ),
    r'userCount': PropertySchema(
      id: 9,
      name: r'userCount',
      type: IsarType.long,
    ),
    r'verified': PropertySchema(
      id: 10,
      name: r'verified',
      type: IsarType.bool,
    )
  },
  estimateSize: _communityTimetableEntityEstimateSize,
  serialize: _communityTimetableEntitySerialize,
  deserialize: _communityTimetableEntityDeserialize,
  deserializeProp: _communityTimetableEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'matchKey': IndexSchema(
      id: -2311115296601403882,
      name: r'matchKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'matchKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _communityTimetableEntityGetId,
  getLinks: _communityTimetableEntityGetLinks,
  attach: _communityTimetableEntityAttach,
  version: '3.1.0+1',
);

int _communityTimetableEntityEstimateSize(
  CommunityTimetableEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.branch.length * 3;
  {
    final value = object.creatorId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.creatorName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.json.length * 3;
  bytesCount += 3 + object.matchKey.length * 3;
  bytesCount += 3 + object.section.length * 3;
  bytesCount += 3 + object.semester.length * 3;
  bytesCount += 3 + object.university.length * 3;
  return bytesCount;
}

void _communityTimetableEntitySerialize(
  CommunityTimetableEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.branch);
  writer.writeString(offsets[1], object.creatorId);
  writer.writeString(offsets[2], object.creatorName);
  writer.writeString(offsets[3], object.json);
  writer.writeString(offsets[4], object.matchKey);
  writer.writeString(offsets[5], object.section);
  writer.writeString(offsets[6], object.semester);
  writer.writeString(offsets[7], object.university);
  writer.writeLong(offsets[8], object.updatedAtMs);
  writer.writeLong(offsets[9], object.userCount);
  writer.writeBool(offsets[10], object.verified);
}

CommunityTimetableEntity _communityTimetableEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CommunityTimetableEntity();
  object.branch = reader.readString(offsets[0]);
  object.creatorId = reader.readStringOrNull(offsets[1]);
  object.creatorName = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.json = reader.readString(offsets[3]);
  object.matchKey = reader.readString(offsets[4]);
  object.section = reader.readString(offsets[5]);
  object.semester = reader.readString(offsets[6]);
  object.university = reader.readString(offsets[7]);
  object.updatedAtMs = reader.readLong(offsets[8]);
  object.userCount = reader.readLong(offsets[9]);
  object.verified = reader.readBool(offsets[10]);
  return object;
}

P _communityTimetableEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _communityTimetableEntityGetId(CommunityTimetableEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _communityTimetableEntityGetLinks(
    CommunityTimetableEntity object) {
  return [];
}

void _communityTimetableEntityAttach(
    IsarCollection<dynamic> col, Id id, CommunityTimetableEntity object) {
  object.id = id;
}

extension CommunityTimetableEntityByIndex
    on IsarCollection<CommunityTimetableEntity> {
  Future<CommunityTimetableEntity?> getByMatchKey(String matchKey) {
    return getByIndex(r'matchKey', [matchKey]);
  }

  CommunityTimetableEntity? getByMatchKeySync(String matchKey) {
    return getByIndexSync(r'matchKey', [matchKey]);
  }

  Future<bool> deleteByMatchKey(String matchKey) {
    return deleteByIndex(r'matchKey', [matchKey]);
  }

  bool deleteByMatchKeySync(String matchKey) {
    return deleteByIndexSync(r'matchKey', [matchKey]);
  }

  Future<List<CommunityTimetableEntity?>> getAllByMatchKey(
      List<String> matchKeyValues) {
    final values = matchKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'matchKey', values);
  }

  List<CommunityTimetableEntity?> getAllByMatchKeySync(
      List<String> matchKeyValues) {
    final values = matchKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'matchKey', values);
  }

  Future<int> deleteAllByMatchKey(List<String> matchKeyValues) {
    final values = matchKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'matchKey', values);
  }

  int deleteAllByMatchKeySync(List<String> matchKeyValues) {
    final values = matchKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'matchKey', values);
  }

  Future<Id> putByMatchKey(CommunityTimetableEntity object) {
    return putByIndex(r'matchKey', object);
  }

  Id putByMatchKeySync(CommunityTimetableEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'matchKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMatchKey(List<CommunityTimetableEntity> objects) {
    return putAllByIndex(r'matchKey', objects);
  }

  List<Id> putAllByMatchKeySync(List<CommunityTimetableEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'matchKey', objects, saveLinks: saveLinks);
  }
}

extension CommunityTimetableEntityQueryWhereSort on QueryBuilder<
    CommunityTimetableEntity, CommunityTimetableEntity, QWhere> {
  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CommunityTimetableEntityQueryWhere on QueryBuilder<
    CommunityTimetableEntity, CommunityTimetableEntity, QWhereClause> {
  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterWhereClause> matchKeyEqualTo(String matchKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'matchKey',
        value: [matchKey],
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterWhereClause> matchKeyNotEqualTo(String matchKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'matchKey',
              lower: [],
              upper: [matchKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'matchKey',
              lower: [matchKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'matchKey',
              lower: [matchKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'matchKey',
              lower: [],
              upper: [matchKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CommunityTimetableEntityQueryFilter on QueryBuilder<
    CommunityTimetableEntity, CommunityTimetableEntity, QFilterCondition> {
  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> branchEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'branch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> branchGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'branch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> branchLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'branch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> branchBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'branch',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> branchStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'branch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> branchEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'branch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      branchContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'branch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      branchMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'branch',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> branchIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'branch',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> branchIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'branch',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'creatorId',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'creatorId',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creatorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'creatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'creatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      creatorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'creatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      creatorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'creatorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorId',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'creatorId',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'creatorName',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'creatorName',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creatorName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'creatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'creatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      creatorNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'creatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      creatorNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'creatorName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorName',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> creatorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'creatorName',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> jsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> jsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> jsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> jsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'json',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> jsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> jsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      jsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      jsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'json',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> jsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'json',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> jsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'json',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> matchKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'matchKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> matchKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'matchKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> matchKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'matchKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> matchKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'matchKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> matchKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'matchKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> matchKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'matchKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      matchKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'matchKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      matchKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'matchKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> matchKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'matchKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> matchKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'matchKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> sectionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'section',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> sectionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'section',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> sectionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'section',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> sectionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'section',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> sectionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'section',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> sectionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'section',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      sectionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'section',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      sectionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'section',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> sectionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'section',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> sectionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'section',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> semesterEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semester',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> semesterGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'semester',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> semesterLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'semester',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> semesterBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'semester',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> semesterStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'semester',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> semesterEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'semester',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      semesterContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'semester',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      semesterMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'semester',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> semesterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semester',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> semesterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'semester',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> universityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'university',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> universityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'university',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> universityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'university',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> universityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'university',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> universityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'university',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> universityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'university',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      universityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'university',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
          QAfterFilterCondition>
      universityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'university',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> universityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'university',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> universityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'university',
        value: '',
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> updatedAtMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> updatedAtMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> updatedAtMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> updatedAtMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAtMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> userCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> userCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> userCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> userCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity,
      QAfterFilterCondition> verifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verified',
        value: value,
      ));
    });
  }
}

extension CommunityTimetableEntityQueryObject on QueryBuilder<
    CommunityTimetableEntity, CommunityTimetableEntity, QFilterCondition> {}

extension CommunityTimetableEntityQueryLinks on QueryBuilder<
    CommunityTimetableEntity, CommunityTimetableEntity, QFilterCondition> {}

extension CommunityTimetableEntityQuerySortBy on QueryBuilder<
    CommunityTimetableEntity, CommunityTimetableEntity, QSortBy> {
  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByBranch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branch', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByBranchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branch', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByCreatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorId', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByCreatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorId', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByCreatorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorName', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByCreatorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorName', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByMatchKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchKey', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByMatchKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchKey', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortBySection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'section', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortBySectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'section', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortBySemester() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semester', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortBySemesterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semester', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByUniversity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'university', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByUniversityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'university', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByUpdatedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByUserCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userCount', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByUserCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userCount', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      sortByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension CommunityTimetableEntityQuerySortThenBy on QueryBuilder<
    CommunityTimetableEntity, CommunityTimetableEntity, QSortThenBy> {
  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByBranch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branch', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByBranchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branch', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByCreatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorId', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByCreatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorId', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByCreatorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorName', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByCreatorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorName', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByMatchKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchKey', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByMatchKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchKey', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenBySection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'section', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenBySectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'section', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenBySemester() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semester', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenBySemesterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semester', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByUniversity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'university', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByUniversityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'university', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByUpdatedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByUserCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userCount', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByUserCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userCount', Sort.desc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QAfterSortBy>
      thenByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension CommunityTimetableEntityQueryWhereDistinct on QueryBuilder<
    CommunityTimetableEntity, CommunityTimetableEntity, QDistinct> {
  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctByBranch({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'branch', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctByCreatorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creatorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctByCreatorName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creatorName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctByJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'json', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctByMatchKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'matchKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctBySection({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'section', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctBySemester({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'semester', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctByUniversity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'university', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAtMs');
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctByUserCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userCount');
    });
  }

  QueryBuilder<CommunityTimetableEntity, CommunityTimetableEntity, QDistinct>
      distinctByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verified');
    });
  }
}

extension CommunityTimetableEntityQueryProperty on QueryBuilder<
    CommunityTimetableEntity, CommunityTimetableEntity, QQueryProperty> {
  QueryBuilder<CommunityTimetableEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CommunityTimetableEntity, String, QQueryOperations>
      branchProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'branch');
    });
  }

  QueryBuilder<CommunityTimetableEntity, String?, QQueryOperations>
      creatorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creatorId');
    });
  }

  QueryBuilder<CommunityTimetableEntity, String?, QQueryOperations>
      creatorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creatorName');
    });
  }

  QueryBuilder<CommunityTimetableEntity, String, QQueryOperations>
      jsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'json');
    });
  }

  QueryBuilder<CommunityTimetableEntity, String, QQueryOperations>
      matchKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'matchKey');
    });
  }

  QueryBuilder<CommunityTimetableEntity, String, QQueryOperations>
      sectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'section');
    });
  }

  QueryBuilder<CommunityTimetableEntity, String, QQueryOperations>
      semesterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semester');
    });
  }

  QueryBuilder<CommunityTimetableEntity, String, QQueryOperations>
      universityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'university');
    });
  }

  QueryBuilder<CommunityTimetableEntity, int, QQueryOperations>
      updatedAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAtMs');
    });
  }

  QueryBuilder<CommunityTimetableEntity, int, QQueryOperations>
      userCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userCount');
    });
  }

  QueryBuilder<CommunityTimetableEntity, bool, QQueryOperations>
      verifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verified');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppPrefsEntityCollection on Isar {
  IsarCollection<AppPrefsEntity> get appPrefsEntitys => this.collection();
}

const AppPrefsEntitySchema = CollectionSchema(
  name: r'AppPrefsEntity',
  id: -6704509916744498669,
  properties: {
    r'deviceId': PropertySchema(
      id: 0,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'onboarded': PropertySchema(
      id: 1,
      name: r'onboarded',
      type: IsarType.bool,
    )
  },
  estimateSize: _appPrefsEntityEstimateSize,
  serialize: _appPrefsEntitySerialize,
  deserialize: _appPrefsEntityDeserialize,
  deserializeProp: _appPrefsEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appPrefsEntityGetId,
  getLinks: _appPrefsEntityGetLinks,
  attach: _appPrefsEntityAttach,
  version: '3.1.0+1',
);

int _appPrefsEntityEstimateSize(
  AppPrefsEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  return bytesCount;
}

void _appPrefsEntitySerialize(
  AppPrefsEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.deviceId);
  writer.writeBool(offsets[1], object.onboarded);
}

AppPrefsEntity _appPrefsEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppPrefsEntity();
  object.deviceId = reader.readString(offsets[0]);
  object.id = id;
  object.onboarded = reader.readBool(offsets[1]);
  return object;
}

P _appPrefsEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appPrefsEntityGetId(AppPrefsEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appPrefsEntityGetLinks(AppPrefsEntity object) {
  return [];
}

void _appPrefsEntityAttach(
    IsarCollection<dynamic> col, Id id, AppPrefsEntity object) {
  object.id = id;
}

extension AppPrefsEntityQueryWhereSort
    on QueryBuilder<AppPrefsEntity, AppPrefsEntity, QWhere> {
  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppPrefsEntityQueryWhere
    on QueryBuilder<AppPrefsEntity, AppPrefsEntity, QWhereClause> {
  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppPrefsEntityQueryFilter
    on QueryBuilder<AppPrefsEntity, AppPrefsEntity, QFilterCondition> {
  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterFilterCondition>
      onboardedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onboarded',
        value: value,
      ));
    });
  }
}

extension AppPrefsEntityQueryObject
    on QueryBuilder<AppPrefsEntity, AppPrefsEntity, QFilterCondition> {}

extension AppPrefsEntityQueryLinks
    on QueryBuilder<AppPrefsEntity, AppPrefsEntity, QFilterCondition> {}

extension AppPrefsEntityQuerySortBy
    on QueryBuilder<AppPrefsEntity, AppPrefsEntity, QSortBy> {
  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy> sortByOnboarded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboarded', Sort.asc);
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy>
      sortByOnboardedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboarded', Sort.desc);
    });
  }
}

extension AppPrefsEntityQuerySortThenBy
    on QueryBuilder<AppPrefsEntity, AppPrefsEntity, QSortThenBy> {
  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy> thenByOnboarded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboarded', Sort.asc);
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QAfterSortBy>
      thenByOnboardedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboarded', Sort.desc);
    });
  }
}

extension AppPrefsEntityQueryWhereDistinct
    on QueryBuilder<AppPrefsEntity, AppPrefsEntity, QDistinct> {
  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppPrefsEntity, AppPrefsEntity, QDistinct>
      distinctByOnboarded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboarded');
    });
  }
}

extension AppPrefsEntityQueryProperty
    on QueryBuilder<AppPrefsEntity, AppPrefsEntity, QQueryProperty> {
  QueryBuilder<AppPrefsEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppPrefsEntity, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<AppPrefsEntity, bool, QQueryOperations> onboardedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboarded');
    });
  }
}
