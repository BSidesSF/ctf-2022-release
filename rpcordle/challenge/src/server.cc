#include <string>
#include <memory>
#include <stdio.h>

#include <grpcpp/ext/proto_server_reflection_plugin.h>
#include <grpcpp/grpcpp.h>
#include <grpcpp/health_check_service_interface.h>

#include "game.h"

#include "src/rpcordle.grpc.pb.h"

using grpc::Status;

class RPCordleServerImpl: public rpcordle::RPCordleServer::Service {
  GameManager *game_manager;

  Status StartGame(
      grpc::ServerContext *ctx,
      const rpcordle::StartGameRequest *request,
      rpcordle::StartGameResponse *response
      ) override {
    int gameid = game_manager->start_game();
    if (gameid == -1) {
      return Status(grpc::StatusCode::RESOURCE_EXHAUSTED, "Too many games in progress");
    }
    response->set_serverid((uint64_t)game_manager);
    response->set_gameid((uint32_t)gameid);
    return Status::OK;
  }

  Status SetMetadata(
      grpc::ServerContext *ctx,
      const rpcordle::SetMetadataRequest *request,
      rpcordle::SetMetadataResponse *response
      ) override {
    GameState *state = game_manager->get_game((int)request->gameid());
    if (state == NULL) {
      return Status(grpc::StatusCode::NOT_FOUND, "Game ID not found!");
    }
    state->set_metadata(request->client_ip().c_str(), request->game_streak());
    return Status::OK;
  }

  Status SubmitGuess(
      grpc::ServerContext *ctx,
      const rpcordle::GuessRequest *request,
      rpcordle::GuessResponse *response
      ) override {
    GameState *state = game_manager->get_game((int)request->gameid());
    if (state == NULL) {
      return Status(grpc::StatusCode::NOT_FOUND, "Game ID not found!");
    }
    ResultValue matches[WORD_LEN];
    int rv = state->guess(request->guess().c_str(), matches);
    if (rv == 2) {
      return Status(grpc::StatusCode::OUT_OF_RANGE, "Ran out of requests!");
    }
    response->set_win(state->won());
    if (state->won()) {
      int record = game_manager->end_game(request->gameid());
      response->set_game_record_id((uint32_t)record);
    }
    for (int i=0; i<WORD_LEN; i++) {
      rpcordle::GuessPosition pos = rpcordle::GuessPosition::NOT_IN_WORD;
      switch (matches[i]) {
        case MATCH_OK:
          pos = rpcordle::GuessPosition::CORRECT;
          break;
        case MATCH_BADPOS:
          pos = rpcordle::GuessPosition::WRONG_POSITION;
          break;
        default:
          break;
      }
      response->add_positions(pos);
    }
    return Status::OK;
  }

  Status EndGame(
      grpc::ServerContext *ctx,
      const rpcordle::EndGameRequest *request,
      rpcordle::EndGameResponse *response
      ) override {
    GameState *state = game_manager->get_game((int)request->gameid());
    if (state == NULL) {
      return Status(grpc::StatusCode::NOT_FOUND, "Game ID not found!");
    }
    response->set_win(state->won());
    int record = game_manager->end_game(request->gameid());
    response->set_game_record_id((uint32_t)record);
    return Status::OK;
  }

  Status GetWordlist(
      grpc::ServerContext *ctx,
      const rpcordle::GetWordlistRequest *request,
      rpcordle::GetWordlistResponse *response
      ) override {
    for (std::string s : game_manager->read_wordlist()) {
      std::string *word = response->add_word();
      *word = s;
    }
    return Status::OK;
  }

  Status GetGameRecord(
      grpc::ServerContext *ctx,
      const rpcordle::GameRecordRequest *request,
      rpcordle::GameRecordResponse *response
      ) override {
    GameRecord *record = this->game_manager->get_game_record(
        (int)request->game_record_id());
    if (record == NULL) {
      return Status(grpc::StatusCode::NOT_FOUND, "Game record ID not found!");
    }
    return SerializeGameRecord(record, response);
  }

  Status EditGameRecord(
      grpc::ServerContext *ctx,
      const rpcordle::GameRecordEditRequest *request,
      rpcordle::GameRecordResponse *response
      ) override {
    GameRecord *record = this->game_manager->get_game_record(
        (int)request->game_record_id());
    if (record == NULL) {
      return Status(grpc::StatusCode::NOT_FOUND, "Game record ID not found!");
    }
    record->set_name(request->name().c_str());
    return SerializeGameRecord(record, response);
  }

  Status SerializeGameRecord(
      const GameRecord *record, rpcordle::GameRecordResponse *response) {
    response->set_game_record_id(record->get_id());
    response->set_name(record->get_name());
    response->set_guesses(record->get_guesses());
    response->set_word(record->get_target_word());
    return Status::OK;
  }

  public:
  RPCordleServerImpl(GameManager *manager): game_manager(manager) {
  }
};

void RunServer(GameManager *manager, std::string address) {
  RPCordleServerImpl service(manager);

  // Setup grpc
  grpc::EnableDefaultHealthCheckService(true);
  grpc::reflection::InitProtoReflectionServerBuilderPlugin();
  grpc::ServerBuilder builder;
  builder.AddListeningPort(address, grpc::InsecureServerCredentials());
  builder.RegisterService(&service);
  std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
  fprintf(stderr, "Listening on %s\n", address.c_str());
  server->Wait();
}

void RunServerForFD(GameManager *manager, int fd) {
  RPCordleServerImpl service(manager);

  // Setup grpc
  grpc::EnableDefaultHealthCheckService(true);
  grpc::reflection::InitProtoReflectionServerBuilderPlugin();
  grpc::ServerBuilder builder;
  builder.RegisterService(&service);
  std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
  grpc::AddInsecureChannelFromFd(server.get(), fd);
  server->Wait();
}
